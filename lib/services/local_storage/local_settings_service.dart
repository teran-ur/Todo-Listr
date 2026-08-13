import 'dart:async';
import '../../features/settings/data/models/user_settings_model.dart';
import '../../features/sync/domain/entities/sync_queue_item.dart';
import 'sync_queue_service.dart';

class LocalSettingsService {
  final SyncQueueService? _syncQueueService;
  final Map<String, UserSettingsModel> _settingsStore = {};
  final StreamController<Map<String, UserSettingsModel>> _streamController =
      StreamController<Map<String, UserSettingsModel>>.broadcast();

  LocalSettingsService({SyncQueueService? syncQueueService})
      : _syncQueueService = syncQueueService;

  Stream<UserSettingsModel> watchSettings(String userId) {
    return _streamController.stream.map((map) {
      return map[userId] ?? const UserSettingsModel();
    });
  }

  Future<UserSettingsModel> getSettings(String userId) async {
    return _settingsStore[userId] ?? const UserSettingsModel();
  }

  Future<void> saveSettings(String userId, UserSettingsModel settings) async {
    _settingsStore[userId] = settings;
    _streamController.add(Map.from(_settingsStore));

    final queue = _syncQueueService;
    if (queue != null) {
      await queue.enqueue(SyncQueueItem(
        queueId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        entityType: SyncEntityType.settings,
        entityId: userId,
        operation: SyncOperation.update,
        payload: settings.toMap(),
        timestamp: DateTime.now(),
      ));
    }
  }

  void dispose() {
    _streamController.close();
  }
}
