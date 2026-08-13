import 'dart:async';
import '../../features/groups/data/models/task_group_model.dart';
import '../../features/settings/data/models/user_settings_model.dart';
import '../../features/sync/domain/entities/sync_queue_item.dart';
import '../../features/sync/domain/entities/sync_status.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../local_storage/local_group_service.dart';
import '../local_storage/local_settings_service.dart';
import '../local_storage/local_task_service.dart';
import '../local_storage/sync_queue_service.dart';
import '../network/connectivity_service.dart';
import '../remote_storage/firestore_group_service.dart';
import '../remote_storage/firestore_settings_service.dart';
import '../remote_storage/firestore_task_service.dart';
import 'sync_service.dart';

class SyncServiceImpl implements SyncService {
  final ConnectivityService _connectivityService;
  final SyncQueueService _syncQueueService;
  final FirestoreTaskService _remoteTaskService;
  final FirestoreGroupService _remoteGroupService;
  final FirestoreSettingsService _remoteSettingsService;
  final LocalTaskService _localTaskService;
  final LocalGroupService _localGroupService;
  final LocalSettingsService _localSettingsService;

  final StreamController<SyncStatusEntity> _statusController =
      StreamController<SyncStatusEntity>.broadcast();

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _taskRemoteSubscription;
  StreamSubscription? _groupRemoteSubscription;
  StreamSubscription? _settingsRemoteSubscription;

  bool _isSyncing = false;
  DateTime? _lastSyncedAt;
  String? _currentUserId;

  SyncServiceImpl({
    required ConnectivityService connectivityService,
    required SyncQueueService syncQueueService,
    required FirestoreTaskService remoteTaskService,
    required FirestoreGroupService remoteGroupService,
    required FirestoreSettingsService remoteSettingsService,
    required LocalTaskService localTaskService,
    required LocalGroupService localGroupService,
    required LocalSettingsService localSettingsService,
  })  : _connectivityService = connectivityService,
        _syncQueueService = syncQueueService,
        _remoteTaskService = remoteTaskService,
        _remoteGroupService = remoteGroupService,
        _remoteSettingsService = remoteSettingsService,
        _localTaskService = localTaskService,
        _localGroupService = localGroupService,
        _localSettingsService = localSettingsService {
    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline && _currentUserId != null) {
        triggerSync(userId: _currentUserId!);
      } else {
        _emitStatus(SyncState.offline);
      }
    });
  }

  @override
  Stream<SyncStatusEntity> get statusStream => _statusController.stream;

  @override
  void startAutoSync({required String userId}) {
    _currentUserId = userId;
    if (!_connectivityService.isOnline) {
      _emitStatus(SyncState.offline);
      return;
    }

    // Downstream Real-time Listeners (Pull Pipeline)
    _taskRemoteSubscription?.cancel();
    _taskRemoteSubscription = _remoteTaskService.watchTasks(userId).listen(
      (remoteTasks) => _reconcileTasks(userId, remoteTasks),
      onError: (e) => _emitStatus(SyncState.error, errorMessage: e.toString()),
    );

    _groupRemoteSubscription?.cancel();
    _groupRemoteSubscription = _remoteGroupService.watchGroups(userId).listen(
      (remoteGroups) => _reconcileGroups(userId, remoteGroups),
      onError: (e) => _emitStatus(SyncState.error, errorMessage: e.toString()),
    );

    _settingsRemoteSubscription?.cancel();
    _settingsRemoteSubscription = _remoteSettingsService.watchSettings(userId).listen(
      (remoteSettings) => _reconcileSettings(userId, remoteSettings),
      onError: (e) => _emitStatus(SyncState.error, errorMessage: e.toString()),
    );

    // Immediate Upstream Push
    triggerSync(userId: userId);
  }

  @override
  void stopAutoSync() {
    _taskRemoteSubscription?.cancel();
    _groupRemoteSubscription?.cancel();
    _settingsRemoteSubscription?.cancel();
    _currentUserId = null;
  }

  @override
  Future<void> triggerSync({required String userId}) async {
    if (_isSyncing || !_connectivityService.isOnline) return;

    _isSyncing = true;
    _emitStatus(SyncState.syncing);

    try {
      final pendingQueue = await _syncQueueService.getPendingQueue(userId);

      for (final item in pendingQueue) {
        await _processQueueItem(item);
        await _syncQueueService.remove(item.queueId);
      }

      _lastSyncedAt = DateTime.now();
      _isSyncing = false;
      _emitStatus(SyncState.success);
    } catch (e) {
      _isSyncing = false;
      _emitStatus(SyncState.error, errorMessage: e.toString());
    }
  }

  Future<void> _processQueueItem(SyncQueueItem item) async {
    if (item.entityType == SyncEntityType.task) {
      if (item.operation == SyncOperation.delete) {
        await _remoteTaskService.deleteTask(item.userId, item.entityId);
      } else {
        final model = TaskModel.fromFirestoreMap(item.payload);
        await _remoteTaskService.saveTask(model);
      }
    } else if (item.entityType == SyncEntityType.group) {
      if (item.operation == SyncOperation.delete) {
        await _remoteGroupService.deleteGroup(item.userId, item.entityId);
      } else {
        final model = TaskGroupModel.fromFirestoreMap(item.payload);
        await _remoteGroupService.saveGroup(model);
      }
    } else if (item.entityType == SyncEntityType.settings) {
      final model = UserSettingsModel.fromMap(item.payload);
      await _remoteSettingsService.saveSettings(item.userId, model);
    }
  }

  /// Reconcile remote task snapshot into local storage using Last-Write-Wins (LWW)
  Future<void> _reconcileTasks(String userId, List<TaskModel> remoteTasks) async {
    final localTasks = await _localTaskService.getTasks(userId);
    final localMap = {for (var t in localTasks) t.id: t};

    for (final remote in remoteTasks) {
      final local = localMap[remote.id];

      if (local == null) {
        // New remote task -> save locally
        await _localTaskService.saveTask(remote);
      } else {
        // Last-Write-Wins (LWW) comparison based on updatedAt
        final remoteDeleted = remote.deletedAt != null;
        final localDeleted = local.deletedAt != null;

        if (remoteDeleted && !localDeleted) {
          await _localTaskService.deleteTask(userId, remote.id);
        } else if (remote.updatedAt.isAfter(local.updatedAt)) {
          await _localTaskService.saveTask(remote);
        }
      }
    }
  }

  /// Reconcile remote group snapshot into local storage using Last-Write-Wins (LWW)
  Future<void> _reconcileGroups(String userId, List<TaskGroupModel> remoteGroups) async {
    final localGroups = await _localGroupService.getGroups(userId);
    final localMap = {for (var g in localGroups) g.id: g};

    for (final remote in remoteGroups) {
      final local = localMap[remote.id];

      if (local == null) {
        await _localGroupService.saveGroup(remote);
      } else {
        final remoteDeleted = remote.deletedAt != null;
        final localDeleted = local.deletedAt != null;

        if (remoteDeleted && !localDeleted) {
          await _localGroupService.deleteGroup(userId, remote.id);
        } else if (remote.updatedAt.isAfter(local.updatedAt)) {
          await _localGroupService.saveGroup(remote);
        }
      }
    }
  }

  /// Reconcile remote settings snapshot into local storage
  Future<void> _reconcileSettings(String userId, UserSettingsModel remoteSettings) async {
    await _localSettingsService.saveSettings(userId, remoteSettings);
  }

  void _emitStatus(SyncState state, {String? errorMessage}) async {
    final pendingCount = _currentUserId != null
        ? (await _syncQueueService.getPendingQueue(_currentUserId!)).length
        : 0;

    _statusController.add(SyncStatusEntity(
      state: state,
      pendingQueueLength: pendingCount,
      lastSyncedAt: _lastSyncedAt,
      errorMessage: errorMessage,
    ));
  }

  void dispose() {
    stopAutoSync();
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}
