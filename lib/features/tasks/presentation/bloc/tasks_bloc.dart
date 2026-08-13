import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_tasks.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final WatchTasks _watchTasks;
  final CreateTaskUseCase _createTask;
  final UpdateTaskUseCase _updateTask;
  final DeleteTaskUseCase _deleteTask;
  final ToggleTaskCompletionUseCase _toggleTaskCompletion;

  StreamSubscription? _tasksSubscription;

  TasksBloc({
    required WatchTasks watchTasks,
    required CreateTaskUseCase createTask,
    required UpdateTaskUseCase updateTask,
    required DeleteTaskUseCase deleteTask,
    required ToggleTaskCompletionUseCase toggleTaskCompletion,
  })  : _watchTasks = watchTasks,
        _createTask = createTask,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        _toggleTaskCompletion = toggleTaskCompletion,
        super(TasksInitial()) {
    on<LoadTasksRequested>(_onLoadTasksRequested);
    on<TasksUpdated>(_onTasksUpdated);
    on<FilterCategoryChanged>(_onFilterCategoryChanged);
    on<SelectedGroupChanged>(_onSelectedGroupChanged);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SortOptionChanged>(_onSortOptionChanged);
    on<AddTaskRequested>(_onAddTaskRequested);
    on<UpdateTaskRequested>(_onUpdateTaskRequested);
    on<DeleteTaskRequested>(_onDeleteTaskRequested);
    on<ToggleTaskCompletionRequested>(_onToggleTaskCompletionRequested);
  }

  void _onLoadTasksRequested(
    LoadTasksRequested event,
    Emitter<TasksState> emit,
  ) {
    emit(TasksLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = _watchTasks(event.userId).listen(
      (tasks) => add(TasksUpdated(tasks)),
      onError: (error) => emit(TasksError(error.toString())),
    );
  }

  void _onTasksUpdated(
    TasksUpdated event,
    Emitter<TasksState> emit,
  ) {
    final activeFilter =
        state is TasksLoaded ? (state as TasksLoaded).activeFilter : TaskFilterCategory.all;
    final selectedGroupId =
        state is TasksLoaded ? (state as TasksLoaded).selectedGroupId : null;
    final searchQuery =
        state is TasksLoaded ? (state as TasksLoaded).searchQuery : '';
    final activeSort =
        state is TasksLoaded ? (state as TasksLoaded).activeSort : TaskSortOption.createdAt;

    final filtered = _filterAndSortTasks(
      allTasks: event.tasks,
      filter: activeFilter,
      groupId: selectedGroupId,
      searchQuery: searchQuery,
      sortOption: activeSort,
    );

    final validTasks = event.tasks.where((t) => t.deletedAt == null).toList();

    emit(TasksLoaded(
      allTasks: event.tasks,
      filteredTasks: filtered,
      activeFilter: activeFilter,
      selectedGroupId: selectedGroupId,
      searchQuery: searchQuery,
      activeSort: activeSort,
      totalCount: validTasks.length,
      todayCount: validTasks.where((t) => t.isDueToday).length,
      upcomingCount: validTasks.where((t) => t.isUpcoming).length,
      overdueCount: validTasks.where((t) => t.isOverdue).length,
      completedCount: validTasks.where((t) => t.isCompleted).length,
    ));
  }

  void _onFilterCategoryChanged(
    FilterCategoryChanged event,
    Emitter<TasksState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final filtered = _filterAndSortTasks(
        allTasks: currentState.allTasks,
        filter: event.category,
        groupId: currentState.selectedGroupId,
        searchQuery: currentState.searchQuery,
        sortOption: currentState.activeSort,
      );

      emit(currentState.copyWith(
        activeFilter: event.category,
        filteredTasks: filtered,
      ));
    }
  }

  void _onSelectedGroupChanged(
    SelectedGroupChanged event,
    Emitter<TasksState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final filtered = _filterAndSortTasks(
        allTasks: currentState.allTasks,
        filter: currentState.activeFilter,
        groupId: event.groupId,
        searchQuery: currentState.searchQuery,
        sortOption: currentState.activeSort,
      );

      emit(currentState.copyWith(
        selectedGroupId: event.groupId,
        filteredTasks: filtered,
      ));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<TasksState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final filtered = _filterAndSortTasks(
        allTasks: currentState.allTasks,
        filter: currentState.activeFilter,
        groupId: currentState.selectedGroupId,
        searchQuery: event.query,
        sortOption: currentState.activeSort,
      );

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredTasks: filtered,
      ));
    }
  }

  void _onSortOptionChanged(
    SortOptionChanged event,
    Emitter<TasksState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final filtered = _filterAndSortTasks(
        allTasks: currentState.allTasks,
        filter: currentState.activeFilter,
        groupId: currentState.selectedGroupId,
        searchQuery: currentState.searchQuery,
        sortOption: event.sortOption,
      );

      emit(currentState.copyWith(
        activeSort: event.sortOption,
        filteredTasks: filtered,
      ));
    }
  }

  Future<void> _onAddTaskRequested(
    AddTaskRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _createTask(event.task);
    } catch (e) {
      emit(TasksError('Failed to create task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTaskRequested(
    UpdateTaskRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _updateTask(event.task);
    } catch (e) {
      emit(TasksError('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTaskRequested(
    DeleteTaskRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _deleteTask(DeleteTaskParams(userId: event.userId, taskId: event.taskId));
    } catch (e) {
      emit(TasksError('Failed to delete task: ${e.toString()}'));
    }
  }

  Future<void> _onToggleTaskCompletionRequested(
    ToggleTaskCompletionRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _toggleTaskCompletion(ToggleTaskCompletionParams(
        userId: event.userId,
        taskId: event.taskId,
        isCompleted: event.isCompleted,
      ));
    } catch (e) {
      emit(TasksError('Failed to toggle completion: ${e.toString()}'));
    }
  }

  List<TaskEntity> _filterAndSortTasks({
    required List<TaskEntity> allTasks,
    required TaskFilterCategory filter,
    required String? groupId,
    required String searchQuery,
    required TaskSortOption sortOption,
  }) {
    var result = allTasks.where((task) => task.deletedAt == null).toList();

    // Filter by group
    if (groupId != null) {
      result = result.where((t) => t.groupId == groupId).toList();
    }

    // Filter by category
    switch (filter) {
      case TaskFilterCategory.today:
        result = result.where((t) => t.isDueToday).toList();
        break;
      case TaskFilterCategory.upcoming:
        result = result.where((t) => t.isUpcoming).toList();
        break;
      case TaskFilterCategory.overdue:
        result = result.where((t) => t.isOverdue).toList();
        break;
      case TaskFilterCategory.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case TaskFilterCategory.all:
        break;
    }

    // Filter by search query
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      result = result.where((t) {
        final titleMatch = t.title.toLowerCase().contains(query);
        final descMatch = t.description?.toLowerCase().contains(query) ?? false;
        return titleMatch || descMatch;
      }).toList();
    }

    // Sort tasks
    result.sort((a, b) {
      switch (sortOption) {
        case TaskSortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case TaskSortOption.priority:
          return b.priority.index.compareTo(a.priority.index);
        case TaskSortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case TaskSortOption.createdAt:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return result;
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
