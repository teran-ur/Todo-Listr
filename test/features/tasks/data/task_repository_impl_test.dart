import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/tasks/data/models/task_model.dart';
import 'package:todo_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/services/local_storage/local_task_service.dart';
import 'package:todo_app/services/remote_storage/firestore_task_service.dart';

class MockLocalTaskService extends Mock implements LocalTaskService {}
class MockFirestoreTaskService extends Mock implements FirestoreTaskService {}

void main() {
  late TaskRepositoryImpl repository;
  late MockLocalTaskService mockLocalTaskService;
  late MockFirestoreTaskService mockFirestoreTaskService;

  final tTask = TaskEntity(
    id: 'task-1',
    ownerId: 'user-123',
    groupId: 'default',
    title: 'Buy groceries',
    description: 'Milk, Eggs, Bread',
    priority: TaskPriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final tTaskModel = TaskModel.fromEntity(tTask);

  setUp(() {
    mockLocalTaskService = MockLocalTaskService();
    mockFirestoreTaskService = MockFirestoreTaskService();
    repository = TaskRepositoryImpl(
      localTaskService: mockLocalTaskService,
      remoteTaskService: mockFirestoreTaskService,
    );

    registerFallbackValue(tTaskModel);
  });

  group('createTask', () {
    test('saves task locally and attempts remote save', () async {
      when(() => mockLocalTaskService.saveTask(any(), isUpdate: any(named: 'isUpdate')))
          .thenAnswer((_) async {});
      when(() => mockFirestoreTaskService.saveTask(any())).thenAnswer((_) async {});

      await repository.createTask(tTask);

      verify(() => mockLocalTaskService.saveTask(tTaskModel, isUpdate: false)).called(1);
      verify(() => mockFirestoreTaskService.saveTask(tTaskModel)).called(1);
    });
  });

  group('toggleTaskCompletion', () {
    test('updates task completion status and saves updated model', () async {
      when(() => mockLocalTaskService.getTasks('user-123'))
          .thenAnswer((_) async => [tTaskModel]);
      when(() => mockLocalTaskService.saveTask(any(), isUpdate: any(named: 'isUpdate')))
          .thenAnswer((_) async {});
      when(() => mockFirestoreTaskService.saveTask(any())).thenAnswer((_) async {});

      await repository.toggleTaskCompletion('user-123', 'task-1', true);

      verify(() => mockLocalTaskService.saveTask(
            any(that: isA<TaskModel>().having((t) => t.isCompleted, 'isCompleted', true)),
            isUpdate: true,
          )).called(1);
    });
  });

  group('deleteTask', () {
    test('soft deletes task locally and remotely', () async {
      when(() => mockLocalTaskService.deleteTask('user-123', 'task-1'))
          .thenAnswer((_) async {});
      when(() => mockFirestoreTaskService.deleteTask('user-123', 'task-1'))
          .thenAnswer((_) async {});

      await repository.deleteTask('user-123', 'task-1');

      verify(() => mockLocalTaskService.deleteTask('user-123', 'task-1')).called(1);
      verify(() => mockFirestoreTaskService.deleteTask('user-123', 'task-1')).called(1);
    });
  });

  group('user isolation', () {
    test('watchTasks queries local storage strictly for given userId', () async {
      when(() => mockLocalTaskService.watchTasks('user-123'))
          .thenAnswer((_) => Stream.value([tTaskModel]));

      final stream = repository.watchTasks('user-123');

      expect(await stream.first, [tTaskModel]);
      verify(() => mockLocalTaskService.watchTasks('user-123')).called(1);
    });
  });
}
