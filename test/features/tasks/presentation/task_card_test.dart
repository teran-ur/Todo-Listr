import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_card.dart';

void main() {
  final tTask = TaskEntity(
    id: '1',
    ownerId: 'user-1',
    title: 'Test Task Title',
    description: 'Test Task Description',
    isCompleted: false,
    priority: TaskPriority.high,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  testWidgets('TaskCard displays title, description, priority badge, and check state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: tTask,
            onToggleCompletion: (_) {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Task Title'), findsOneWidget);
    expect(find.text('Test Task Description'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);
    expect(find.byKey(const Key('task_checkbox_1')), findsOneWidget);
  });
}
