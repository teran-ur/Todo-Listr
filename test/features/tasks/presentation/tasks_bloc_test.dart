import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/domain/usecases/create_task.dart';
import 'package:todo_app/features/tasks/domain/usecases/delete_task.dart';
import 'package:todo_app/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:todo_app/features/tasks/domain/usecases/update_task.dart';
import 'package:todo_app/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:todo_app/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:todo_app/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:todo_app/features/tasks/presentation/bloc/tasks_state.dart';

class MockWatchTasks extends Mock implements WatchTasks {}
class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}
class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}
class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}
class MockToggleTaskCompletionUseCase extends Mock
    implements ToggleTaskCompletionUseCase {}

void main() {
  late MockWatchTasks mockWatchTasks;
  late MockCreateTaskUseCase mockCreateTask;
  late MockUpdateTaskUseCase mockUpdateTask;
  late MockDeleteTaskUseCase mockDeleteTask;
  late MockToggleTaskCompletionUseCase mockToggleTaskCompletion;
  late StreamController<List<TaskEntity>> taskStreamController;

  final now = DateTime.now();
  final todayTask = TaskEntity(
    id: 't-today',
    ownerId: 'user-1',
    groupId: 'default',
    title: 'Today Task',
    dueDate: now,
    createdAt: now,
    updatedAt: now,
  );

  final overdueTask = TaskEntity(
    id: 't-overdue',
    ownerId: 'user-1',
    groupId: 'default',
    title: 'Overdue Task',
    dueDate: now.subtract(const Duration(days: 2)),
    createdAt: now.subtract(const Duration(days: 2)),
    updatedAt: now.subtract(const Duration(days: 2)),
  );

  final completedTask = TaskEntity(
    id: 't-completed',
    ownerId: 'user-1',
    groupId: 'default',
    title: 'Completed Task',
    isCompleted: true,
    createdAt: now,
    updatedAt: now,
  );

  final allTasksList = [todayTask, overdueTask, completedTask];

  setUp(() {
    mockWatchTasks = MockWatchTasks();
    mockCreateTask = MockCreateTaskUseCase();
    mockUpdateTask = MockUpdateTaskUseCase();
    mockDeleteTask = MockDeleteTaskUseCase();
    mockToggleTaskCompletion = MockToggleTaskCompletionUseCase();
    taskStreamController = StreamController<List<TaskEntity>>.broadcast();

    when(() => mockWatchTasks('user-1'))
        .thenAnswer((_) => taskStreamController.stream);
  });

  tearDown(() {
    taskStreamController.close();
  });

  blocTest<TasksBloc, TasksState>(
    'emits TasksLoaded with calculated metrics on TasksUpdated',
    build: () => TasksBloc(
      watchTasks: mockWatchTasks,
      createTask: mockCreateTask,
      updateTask: mockUpdateTask,
      deleteTask: mockDeleteTask,
      toggleTaskCompletion: mockToggleTaskCompletion,
    ),
    act: (bloc) async {
      bloc.add(const LoadTasksRequested('user-1'));
      await Future.delayed(const Duration(milliseconds: 10));
      taskStreamController.add(allTasksList);
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<TasksLoading>(),
      isA<TasksLoaded>()
          .having((s) => s.totalCount, 'totalCount', 3)
          .having((s) => s.todayCount, 'todayCount', 1)
          .having((s) => s.overdueCount, 'overdueCount', 1)
          .having((s) => s.completedCount, 'completedCount', 1),
    ],
  );

  blocTest<TasksBloc, TasksState>(
    'filters tasks by Overdue category when FilterCategoryChanged is emitted',
    build: () => TasksBloc(
      watchTasks: mockWatchTasks,
      createTask: mockCreateTask,
      updateTask: mockUpdateTask,
      deleteTask: mockDeleteTask,
      toggleTaskCompletion: mockToggleTaskCompletion,
    ),
    seed: () => TasksLoaded(
      allTasks: allTasksList,
      filteredTasks: allTasksList,
      totalCount: 3,
      todayCount: 1,
      upcomingCount: 0,
      overdueCount: 1,
      completedCount: 1,
    ),
    act: (bloc) => bloc.add(const FilterCategoryChanged(TaskFilterCategory.overdue)),
    expect: () => [
      isA<TasksLoaded>()
          .having((s) => s.activeFilter, 'activeFilter', TaskFilterCategory.overdue)
          .having((s) => s.filteredTasks.length, 'filteredTasks.length', 1)
          .having((s) => s.filteredTasks.first.id, 'first.id', 't-overdue'),
    ],
  );

  blocTest<TasksBloc, TasksState>(
    'filters tasks by search query when SearchQueryChanged is emitted',
    build: () => TasksBloc(
      watchTasks: mockWatchTasks,
      createTask: mockCreateTask,
      updateTask: mockUpdateTask,
      deleteTask: mockDeleteTask,
      toggleTaskCompletion: mockToggleTaskCompletion,
    ),
    seed: () => TasksLoaded(
      allTasks: allTasksList,
      filteredTasks: allTasksList,
      totalCount: 3,
      todayCount: 1,
      upcomingCount: 0,
      overdueCount: 1,
      completedCount: 1,
    ),
    act: (bloc) => bloc.add(const SearchQueryChanged('Overdue')),
    expect: () => [
      isA<TasksLoaded>()
          .having((s) => s.searchQuery, 'searchQuery', 'Overdue')
          .having((s) => s.filteredTasks.length, 'filteredTasks.length', 1)
          .having((s) => s.filteredTasks.first.title, 'title', 'Overdue Task'),
    ],
  );
}
