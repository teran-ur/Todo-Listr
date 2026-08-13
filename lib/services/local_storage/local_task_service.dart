import 'dart:async';
import '../../features/sync/domain/entities/sync_queue_item.dart';
import '../../features/tasks/data/models/task_model.dart';
import 'sync_queue_service.dart';

/// Local in-memory / persistent cache service for tasks with offline queue logging
class LocalTaskService {
  final SyncQueueService? _syncQueueService;
  final Map<String, TaskModel> _taskStore = {};
  final StreamController<List<TaskModel>> _tasksStreamController =
      StreamController<List<TaskModel>>.broadcast();

  LocalTaskService({SyncQueueService? syncQueueService})
      : _syncQueueService = syncQueueService;

  Stream<List<TaskModel>> watchTasks(String userId) {
    return _tasksStreamController.stream.map((tasks) {
      return tasks.where((t) => t.ownerId == userId && t.deletedAt == null).toList();
    });
  }

  Future<List<TaskModel>> getTasks(String userId) async {
    return _taskStore.values
        .where((t) => t.ownerId == userId && t.deletedAt == null)
        .toList();
  }

  Future<void> saveTask(TaskModel task, {bool isUpdate = false}) async {
    _taskStore[task.id] = task;
    _notifyListeners();

    // Log mutation to offline sync queue
    final queue = _syncQueueService;
    if (queue != null) {
      await queue.enqueue(SyncQueueItem(
        queueId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: task.ownerId,
        entityType: SyncEntityType.task,
        entityId: task.id,
        operation: isUpdate ? SyncOperation.update : SyncOperation.create,
        payload: task.toFirestoreMap(),
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    for (final task in tasks) {
      _taskStore[task.id] = task;
    }
    _notifyListeners();
  }

  Future<void> deleteTask(String userId, String taskId) async {
    final existing = _taskStore[taskId];
    if (existing != null && existing.ownerId == userId) {
      final updated = TaskModel.fromEntity(
        existing.copyWith(deletedAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      _taskStore[taskId] = updated;
      _notifyListeners();

      final queue = _syncQueueService;
      if (queue != null) {
        await queue.enqueue(SyncQueueItem(
          queueId: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          entityType: SyncEntityType.task,
          entityId: taskId,
          operation: SyncOperation.delete,
          payload: {'id': taskId},
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  void _notifyListeners() {
    _tasksStreamController.add(_taskStore.values.toList());
  }

  void dispose() {
    _tasksStreamController.close();
  }
}
