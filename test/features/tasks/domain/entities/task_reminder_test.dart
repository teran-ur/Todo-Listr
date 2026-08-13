import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';

void main() {
  test('TaskEntity copyWith updates reminderDateTime and isReminderEnabled', () {
    final task = TaskEntity(
      id: 'rem-test',
      ownerId: 'user-1',
      title: 'Original Title',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(task.isReminderEnabled, isFalse);
    expect(task.reminderDateTime, isNull);

    final futureTime = DateTime.now().add(const Duration(days: 1));
    final updated = task.copyWith(
      reminderDateTime: futureTime,
      isReminderEnabled: true,
    );

    expect(updated.isReminderEnabled, isTrue);
    expect(updated.reminderDateTime, futureTime);
  });
}
