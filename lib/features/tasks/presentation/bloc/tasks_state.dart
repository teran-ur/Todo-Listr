import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskFilterCategory activeFilter;
  final TaskSortOption activeSort;
  final String searchQuery;
  final String? selectedGroupId;
  final int totalCount;
  final int todayCount;
  final int upcomingCount;
  final int overdueCount;
  final int completedCount;

  const TasksLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.activeFilter = TaskFilterCategory.all,
    this.activeSort = TaskSortOption.createdAt,
    this.searchQuery = '',
    this.selectedGroupId,
    required this.totalCount,
    required this.todayCount,
    required this.upcomingCount,
    required this.overdueCount,
    required this.completedCount,
  });

  TasksLoaded copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    TaskFilterCategory? activeFilter,
    TaskSortOption? activeSort,
    String? searchQuery,
    String? selectedGroupId,
    int? totalCount,
    int? todayCount,
    int? upcomingCount,
    int? overdueCount,
    int? completedCount,
  }) {
    return TasksLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      activeFilter: activeFilter ?? this.activeFilter,
      activeSort: activeSort ?? this.activeSort,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      totalCount: totalCount ?? this.totalCount,
      todayCount: todayCount ?? this.todayCount,
      upcomingCount: upcomingCount ?? this.upcomingCount,
      overdueCount: overdueCount ?? this.overdueCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        activeFilter,
        activeSort,
        searchQuery,
        selectedGroupId,
        totalCount,
        todayCount,
        upcomingCount,
        overdueCount,
        completedCount,
      ];
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
}
