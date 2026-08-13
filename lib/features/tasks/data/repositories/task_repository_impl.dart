import '../../../../services/local_storage/local_task_service.dart';
import '../../../../services/notifications/notification_service.dart';
import '../../../../services/remote_storage/firestore_task_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final LocalTaskService _localTaskService;
  final FirestoreTaskService _remoteTaskService;
  final NotificationService? _notificationService;

  TaskRepositoryImpl({
    required LocalTaskService localTaskService,
    required FirestoreTaskService remoteTaskService,
    NotificationService? notificationService,
  })  : _localTaskService = localTaskService,
        _remoteTaskService = remoteTaskService,
        _notificationService = notificationService;

  @override
  Stream<List<TaskEntity>> watchTasks(String userId) {
    return _localTaskService.watchTasks(userId);
  }

  @override
  Future<List<TaskEntity>> getTasks(String userId) async {
    return _localTaskService.getTasks(userId);
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localTaskService.saveTask(model, isUpdate: false);
    await _notificationService?.syncTaskReminder(task);
    try {
      await _remoteTaskService.saveTask(model);
    } catch (_) {}
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    final model = TaskModel.fromEntity(updatedTask);
    await _localTaskService.saveTask(model, isUpdate: true);
    await _notificationService?.syncTaskReminder(updatedTask);
    try {
      await _remoteTaskService.saveTask(model);
    } catch (_) {}
  }

  @override
  Future<void> toggleTaskCompletion(String userId, String taskId, bool isCompleted) async {
    final tasks = await _localTaskService.getTasks(userId);
    final existing = tasks.firstWhere((t) => t.id == taskId);

    final updatedTask = existing.copyWith(
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );

    final model = TaskModel.fromEntity(updatedTask);
    await _localTaskService.saveTask(model, isUpdate: true);
    await _notificationService?.syncTaskReminder(updatedTask);

    try {
      await _remoteTaskService.saveTask(model);
    } catch (_) {}
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _localTaskService.deleteTask(userId, taskId);
    await _notificationService?.cancelTaskReminder(taskId);
    try {
      await _remoteTaskService.deleteTask(userId, taskId);
    } catch (_) {}
  }
}
