import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/services/notifications/notification_service.dart';

void main() {
  late NotificationService notificationService;

  final futureReminder = DateTime.now().add(const Duration(hours: 2));

  final tTaskWithReminder = TaskEntity(
    id: 'rem-1',
    ownerId: 'user-rem',
    title: 'Reminder Task',
    reminderDateTime: futureReminder,
    isReminderEnabled: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    notificationService = NotificationService();
  });

  test('syncTaskReminder schedules notification for future active reminder', () async {
    await notificationService.syncTaskReminder(tTaskWithReminder);

    expect(notificationService.scheduledReminders.containsKey('rem-1'), isTrue);
  });

  test('syncTaskReminder cancels notification if task is completed', () async {
    await notificationService.syncTaskReminder(tTaskWithReminder);
    final completedTask = tTaskWithReminder.copyWith(isCompleted: true);

    await notificationService.syncTaskReminder(completedTask);

    expect(notificationService.scheduledReminders.containsKey('rem-1'), isFalse);
  });

  test('syncTaskReminder cancels notification if reminder is disabled or past', () async {
    await notificationService.syncTaskReminder(tTaskWithReminder);
    final disabledTask = tTaskWithReminder.copyWith(isReminderEnabled: false);

    await notificationService.syncTaskReminder(disabledTask);

    expect(notificationService.scheduledReminders.containsKey('rem-1'), isFalse);
  });
}
