import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/groups/domain/entities/task_group.dart';
import 'package:todo_app/features/groups/domain/usecases/create_group.dart';
import 'package:todo_app/features/groups/domain/usecases/delete_group.dart';
import 'package:todo_app/features/groups/domain/usecases/reorder_groups.dart';
import 'package:todo_app/features/groups/domain/usecases/update_group.dart';
import 'package:todo_app/features/groups/domain/usecases/watch_groups.dart';
import 'package:todo_app/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:todo_app/features/groups/presentation/bloc/groups_event.dart';
import 'package:todo_app/features/groups/presentation/bloc/groups_state.dart';

class MockWatchGroups extends Mock implements WatchGroups {}
class MockCreateGroupUseCase extends Mock implements CreateGroupUseCase {}
class MockUpdateGroupUseCase extends Mock implements UpdateGroupUseCase {}
class MockDeleteGroupUseCase extends Mock implements DeleteGroupUseCase {}
class MockReorderGroupsUseCase extends Mock implements ReorderGroupsUseCase {}

void main() {
  late MockWatchGroups mockWatchGroups;
  late MockCreateGroupUseCase mockCreateGroup;
  late MockUpdateGroupUseCase mockUpdateGroup;
  late MockDeleteGroupUseCase mockDeleteGroup;
  late MockReorderGroupsUseCase mockReorderGroups;
  late StreamController<List<TaskGroupEntity>> groupStreamController;

  final tGroup = TaskGroupEntity(
    id: 'g-1',
    ownerId: 'user-1',
    name: 'Work',
    colorHex: '#2196F3',
    iconName: 'work',
    sortOrder: 0.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockWatchGroups = MockWatchGroups();
    mockCreateGroup = MockCreateGroupUseCase();
    mockUpdateGroup = MockUpdateGroupUseCase();
    mockDeleteGroup = MockDeleteGroupUseCase();
    mockReorderGroups = MockReorderGroupsUseCase();
    groupStreamController = StreamController<List<TaskGroupEntity>>.broadcast();

    when(() => mockWatchGroups('user-1'))
        .thenAnswer((_) => groupStreamController.stream);
  });

  tearDown(() {
    groupStreamController.close();
  });

  blocTest<GroupsBloc, GroupsState>(
    'emits GroupsLoaded when GroupsUpdated is received',
    build: () => GroupsBloc(
      watchGroups: mockWatchGroups,
      createGroup: mockCreateGroup,
      updateGroup: mockUpdateGroup,
      deleteGroup: mockDeleteGroup,
      reorderGroups: mockReorderGroups,
    ),
    act: (bloc) async {
      bloc.add(const LoadGroupsRequested('user-1'));
      await Future.delayed(const Duration(milliseconds: 10));
      groupStreamController.add([tGroup]);
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<GroupsLoading>(),
      GroupsLoaded(allGroups: [tGroup]),
    ],
  );

  blocTest<GroupsBloc, GroupsState>(
    'updates selectedGroupId when SelectGroupEvent is triggered',
    build: () => GroupsBloc(
      watchGroups: mockWatchGroups,
      createGroup: mockCreateGroup,
      updateGroup: mockUpdateGroup,
      deleteGroup: mockDeleteGroup,
      reorderGroups: mockReorderGroups,
    ),
    seed: () => GroupsLoaded(allGroups: [tGroup]),
    act: (bloc) => bloc.add(const SelectGroupEvent('g-1')),
    expect: () => [
      GroupsLoaded(allGroups: [tGroup], selectedGroupId: 'g-1'),
    ],
  );
}
