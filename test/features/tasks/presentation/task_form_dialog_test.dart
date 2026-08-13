import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_form_dialog.dart';

void main() {
  testWidgets('TaskFormDialog creates task when valid title is submitted',
      (tester) async {
    TaskEntity? submittedTask;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => TaskFormDialog(
                    userId: 'user-123',
                    availableGroups: const [],
                    onSubmit: (task) {
                      submittedTask = task;
                    },
                  ),
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task_form_dialog')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('task_title_input')), 'New Form Task');
    await tester.enterText(
        find.byKey(const Key('task_description_input')), 'Form Description');

    await tester.tap(find.byKey(const Key('task_submit_button')));
    await tester.pumpAndSettle();

    expect(submittedTask, isNotNull);
    expect(submittedTask!.title, 'New Form Task');
    expect(submittedTask!.description, 'Form Description');
  });
}
