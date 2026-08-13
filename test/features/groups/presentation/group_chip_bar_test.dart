import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/groups/domain/entities/task_group.dart';
import 'package:todo_app/features/groups/presentation/widgets/group_chip_bar.dart';

void main() {
  final tGroups = [
    TaskGroupEntity(
      id: 'g-uni',
      ownerId: 'user-1',
      name: 'University',
      colorHex: '#2196F3',
      iconName: 'school',
      sortOrder: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    TaskGroupEntity(
      id: 'g-fit',
      ownerId: 'user-1',
      name: 'Fitness',
      colorHex: '#4CAF50',
      iconName: 'fitness',
      sortOrder: 1.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  testWidgets('GroupChipBar renders All Tasks chip and dynamic custom groups',
      (tester) async {
    String? selectedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GroupChipBar(
            groups: tGroups,
            selectedGroupId: selectedId,
            onGroupSelected: (id) => selectedId = id,
            onAddGroup: () {},
            onManageGroups: () {},
          ),
        ),
      ),
    );

    expect(find.text('All Tasks'), findsOneWidget);
    expect(find.text('University'), findsOneWidget);
    expect(find.text('Fitness'), findsOneWidget);

    await tester.tap(find.text('University'));
    expect(selectedId, 'g-uni');
  });
}
