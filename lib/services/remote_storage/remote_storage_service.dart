import '../../features/tasks/domain/entities/task.dart';
import '../../features/groups/domain/entities/task_group.dart';

/// Contract for Cloud Firestore Remote Storage Provider
abstract class RemoteStorageService {
  Future<void> pushTask(TaskEntity task);
  Future<void> deleteTask(String userId, String taskId);
  Stream<List<TaskEntity>> watchTasks(String userId, {DateTime? since});

  Future<void> pushGroup(TaskGroupEntity group);
  Future<void> deleteGroup(String userId, String groupId);
  Stream<List<TaskGroupEntity>> watchGroups(String userId, {DateTime? since});
}
