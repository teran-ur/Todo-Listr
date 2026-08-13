import 'dart:async';
import '../../features/groups/data/models/task_group_model.dart';
import '../../features/sync/domain/entities/sync_queue_item.dart';
import 'sync_queue_service.dart';

/// Local in-memory / persistent cache service for task groups with offline queue logging
class LocalGroupService {
  final SyncQueueService? _syncQueueService;
  final Map<String, TaskGroupModel> _groupStore = {};
  final StreamController<List<TaskGroupModel>> _groupsStreamController =
      StreamController<List<TaskGroupModel>>.broadcast();

  LocalGroupService({SyncQueueService? syncQueueService})
      : _syncQueueService = syncQueueService;

  Stream<List<TaskGroupModel>> watchGroups(String userId) {
    return _groupsStreamController.stream.map((groups) {
      final list = groups.where((g) => g.ownerId == userId && g.deletedAt == null).toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Future<List<TaskGroupModel>> getGroups(String userId) async {
    final list = _groupStore.values
        .where((g) => g.ownerId == userId && g.deletedAt == null)
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<void> saveGroup(TaskGroupModel group, {bool isUpdate = false}) async {
    _groupStore[group.id] = group;
    _notifyListeners();

    final queue = _syncQueueService;
    if (queue != null) {
      await queue.enqueue(SyncQueueItem(
        queueId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: group.ownerId,
        entityType: SyncEntityType.group,
        entityId: group.id,
        operation: isUpdate ? SyncOperation.update : SyncOperation.create,
        payload: group.toFirestoreMap(),
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> saveGroups(List<TaskGroupModel> groups) async {
    for (final group in groups) {
      _groupStore[group.id] = group;
    }
    _notifyListeners();
  }

  Future<void> deleteGroup(String userId, String groupId) async {
    final existing = _groupStore[groupId];
    if (existing != null && existing.ownerId == userId) {
      _groupStore[groupId] = TaskGroupModel.fromEntity(
        existing.copyWith(deletedAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      _notifyListeners();

      final queue = _syncQueueService;
      if (queue != null) {
        await queue.enqueue(SyncQueueItem(
          queueId: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          entityType: SyncEntityType.group,
          entityId: groupId,
          operation: SyncOperation.delete,
          payload: {'id': groupId},
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  void _notifyListeners() {
    _groupsStreamController.add(_groupStore.values.toList());
  }

  void dispose() {
    _groupsStreamController.close();
  }
}
