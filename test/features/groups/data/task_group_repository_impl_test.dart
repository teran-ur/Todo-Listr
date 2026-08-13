import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/groups/data/models/task_group_model.dart';
import 'package:todo_app/features/groups/data/repositories/task_group_repository_impl.dart';
import 'package:todo_app/features/groups/domain/entities/task_group.dart';
import 'package:todo_app/features/tasks/data/models/task_model.dart';
import 'package:todo_app/services/local_storage/local_group_service.dart';
import 'package:todo_app/services/local_storage/local_task_service.dart';
import 'package:todo_app/services/remote_storage/firestore_group_service.dart';
import 'package:todo_app/services/remote_storage/firestore_task_service.dart';

class MockLocalGroupService extends Mock implements LocalGroupService {}
class MockFirestoreGroupService extends Mock implements FirestoreGroupService {}
class MockLocalTaskService extends Mock implements LocalTaskService {}
class MockFirestoreTaskService extends Mock implements FirestoreTaskService {}

void main() {
  late TaskGroupRepositoryImpl repository;
  late MockLocalGroupService mockLocalGroupService;
  late MockFirestoreGroupService mockFirestoreGroupService;
  late MockLocalTaskService mockLocalTaskService;
  late MockFirestoreTaskService mockFirestoreTaskService;

  final tGroup = TaskGroupEntity(
    id: 'group-1',
    ownerId: 'user-123',
    name: 'University',
    colorHex: '#2196F3',
    iconName: 'school',
    sortOrder: 0.0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final tGroupModel = TaskGroupModel.fromEntity(tGroup);

  final tTaskModel = TaskModel(
    id: 'task-1',
    ownerId: 'user-123',
    groupId: 'group-1',
    title: 'Assignment 1',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockLocalGroupService = MockLocalGroupService();
    mockFirestoreGroupService = MockFirestoreGroupService();
    mockLocalTaskService = MockLocalTaskService();
    mockFirestoreTaskService = MockFirestoreTaskService();

    repository = TaskGroupRepositoryImpl(
      localGroupService: mockLocalGroupService,
      remoteGroupService: mockFirestoreGroupService,
      localTaskService: mockLocalTaskService,
      remoteTaskService: mockFirestoreTaskService,
    );

    registerFallbackValue(tGroupModel);
    registerFallbackValue(tTaskModel);
  });

  group('createGroup', () {
    test('saves group locally and remotely', () async {
      when(() => mockLocalGroupService.saveGroup(any(), isUpdate: any(named: 'isUpdate')))
          .thenAnswer((_) async {});
      when(() => mockFirestoreGroupService.saveGroup(any())).thenAnswer((_) async {});

      await repository.createGroup(tGroup);

      verify(() => mockLocalGroupService.saveGroup(tGroupModel, isUpdate: false)).called(1);
      verify(() => mockFirestoreGroupService.saveGroup(tGroupModel)).called(1);
    });
  });

  group('deleteGroup and orphan task reassignment', () {
    test('soft deletes group and reassigns orphan tasks to default group', () async {
      when(() => mockLocalGroupService.deleteGroup('user-123', 'group-1'))
          .thenAnswer((_) async {});
      when(() => mockFirestoreGroupService.deleteGroup('user-123', 'group-1'))
          .thenAnswer((_) async {});
      when(() => mockLocalTaskService.getTasks('user-123'))
          .thenAnswer((_) async => [tTaskModel]);
      when(() => mockLocalTaskService.saveTask(any(), isUpdate: any(named: 'isUpdate')))
          .thenAnswer((_) async {});
      when(() => mockFirestoreTaskService.saveTask(any())).thenAnswer((_) async {});

      await repository.deleteGroup('user-123', 'group-1');

      verify(() => mockLocalGroupService.deleteGroup('user-123', 'group-1')).called(1);
      verify(() => mockLocalTaskService.saveTask(
            any(that: isA<TaskModel>().having((t) => t.groupId, 'groupId', 'default')),
            isUpdate: true,
          )).called(1);
    });
  });

  group('reorderGroups', () {
    test('updates sortOrder for all groups in order', () async {
      final g2 = tGroup.copyWith(id: 'group-2', sortOrder: 1.0);
      when(() => mockLocalGroupService.saveGroup(any(), isUpdate: any(named: 'isUpdate')))
          .thenAnswer((_) async {});
      when(() => mockFirestoreGroupService.saveGroup(any())).thenAnswer((_) async {});

      await repository.reorderGroups('user-123', [g2, tGroup]);

      verify(() => mockLocalGroupService.saveGroup(
            any(
              that: isA<TaskGroupModel>()
                  .having((g) => g.id, 'id', 'group-2')
                  .having((g) => g.sortOrder, 'sortOrder', 0.0),
            ),
            isUpdate: true,
          )).called(1);
    });
  });
}
