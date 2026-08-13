import 'dart:async';
import '../../features/tasks/domain/entities/task.dart';

/// Notification Service handling local task reminder scheduling & auto-cancellation
class NotificationService {
  final Map<String, TaskEntity> _scheduledReminders = {};

  Map<String, TaskEntity> get scheduledReminders => Map.unmodifiable(_scheduledReminders);

  /// Schedule or cancel a task reminder based on task state
  Future<void> syncTaskReminder(TaskEntity task) async {
    final now = DateTime.now();

    // Cancellation conditions: completed, deleted, reminder disabled, or no reminder time set
    if (task.isCompleted ||
        task.deletedAt != null ||
        !task.isReminderEnabled ||
        task.reminderDateTime == null ||
        task.reminderDateTime!.isBefore(now)) {
      await cancelTaskReminder(task.id);
      return;
    }

    // Active future reminder -> Schedule notification
    _scheduledReminders[task.id] = task;
  }

  /// Cancel a scheduled task reminder
  Future<void> cancelTaskReminder(String taskId) async {
    _scheduledReminders.remove(taskId);
  }

  /// Synchronize all reminders for a list of tasks
  Future<void> syncTaskReminders(List<TaskEntity> tasks) async {
    for (final task in tasks) {
      await syncTaskReminder(task);
    }
  }
}
