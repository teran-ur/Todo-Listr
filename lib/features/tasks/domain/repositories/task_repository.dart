import '../entities/task.dart';

/// Domain contract for Task management CRUD operations
abstract class TaskRepository {
  /// Watch live stream of tasks belonging to userId
  Stream<List<TaskEntity>> watchTasks(String userId);

  /// Fetch snapshot of tasks belonging to userId
  Future<List<TaskEntity>> getTasks(String userId);

  /// Create a new task
  Future<void> createTask(TaskEntity task);

  /// Update an existing task
  Future<void> updateTask(TaskEntity task);

  /// Delete a task
  Future<void> deleteTask(String userId, String taskId);

  /// Toggle completion status of a task
  Future<void> toggleTaskCompletion(String userId, String taskId, bool isCompleted);
}
