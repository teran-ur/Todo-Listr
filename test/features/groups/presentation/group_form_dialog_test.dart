import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/groups/domain/entities/task_group.dart';
import 'package:todo_app/features/groups/presentation/widgets/group_form_dialog.dart';

void main() {
  testWidgets('GroupFormDialog creates group when valid name is submitted',
      (tester) async {
    TaskGroupEntity? submittedGroup;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => GroupFormDialog(
                    userId: 'user-123',
                    onSubmit: (group) {
                      submittedGroup = group;
                    },
                  ),
                );
              },
              child: const Text('Open Group Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Group Dialog'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('group_form_dialog')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('group_name_input')), 'University Projects');

    await tester.tap(find.byKey(const Key('group_submit_button')));
    await tester.pumpAndSettle();

    expect(submittedGroup, isNotNull);
    expect(submittedGroup?.name, 'University Projects');
  });
}
