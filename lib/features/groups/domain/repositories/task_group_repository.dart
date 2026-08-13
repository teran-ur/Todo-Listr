import '../entities/task_group.dart';

/// Domain contract for Task Group CRUD operations and reordering
abstract class TaskGroupRepository {
  /// Watch live stream of task groups belonging to userId
  Stream<List<TaskGroupEntity>> watchGroups(String userId);

  /// Fetch snapshot of task groups belonging to userId
  Future<List<TaskGroupEntity>> getGroups(String userId);

  /// Create a new task group
  Future<void> createGroup(TaskGroupEntity group);

  /// Update an existing task group
  Future<void> updateGroup(TaskGroupEntity group);

  /// Delete a task group and reassign orphan tasks to default group
  Future<void> deleteGroup(String userId, String groupId);

  /// Batch update sort order of groups
  Future<void> reorderGroups(String userId, List<TaskGroupEntity> groups);
}
