import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/groups/domain/entities/group_appearance.dart';
import 'package:todo_app/features/groups/domain/entities/task_group.dart';
import 'package:todo_app/features/groups/presentation/widgets/group_customization_dialog.dart';

void main() {
  final tGroup = TaskGroupEntity(
    id: 'g-custom',
    ownerId: 'user-1',
    name: 'Fitness & Health',
    colorHex: '#4CAF50',
    iconName: 'fitness',
    appearance: const GroupAppearanceEntity(
      cardStyle: GroupCardStyle.elevated,
      layoutStyle: GroupLayoutStyle.list,
      progressStyle: GroupProgressStyle.bar,
    ),
    sortOrder: 0.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  testWidgets(
      'GroupCustomizationDialog displays live preview card and saves updated group styling',
      (tester) async {
    TaskGroupEntity? updatedGroup;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => GroupCustomizationDialog(
                    group: tGroup,
                    onSave: (group) => updatedGroup = group,
                  ),
                );
              },
              child: const Text('Open Customization'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Customization'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('group_customization_dialog')), findsOneWidget);
    expect(find.text('Live Visual Preview'), findsOneWidget);
    expect(find.text('Fitness & Health'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save_customization_button')));
    await tester.pumpAndSettle();

    expect(updatedGroup, isNotNull);
    expect(updatedGroup?.name, 'Fitness & Health');
  });
}
