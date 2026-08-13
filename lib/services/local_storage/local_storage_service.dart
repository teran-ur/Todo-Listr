import '../../features/tasks/domain/entities/task.dart';
import '../../features/groups/domain/entities/task_group.dart';

/// Contract for Local Storage Engine (Hive/Drift) supporting offline-first access
abstract class LocalStorageService {
  Future<void> initialize();

  // Task Operations
  Future<List<TaskEntity>> getTasks({required String userId, String? groupId});
  Future<void> saveTask(TaskEntity task);
  Future<void> deleteTask(String taskId);

  // Group Operations
  Future<List<TaskGroupEntity>> getGroups({required String userId});
  Future<void> saveGroup(TaskGroupEntity group);
  Future<void> deleteGroup(String groupId);

  // Sync Queue Operations
  Future<void> enqueueSyncOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  });
  Future<List<Map<String, dynamic>>> getPendingSyncQueue();
  Future<void> dequeueSyncOperation(String queueId);
}
