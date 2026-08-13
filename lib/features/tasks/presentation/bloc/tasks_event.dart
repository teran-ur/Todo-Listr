import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksRequested extends TasksEvent {
  final String userId;

  const LoadTasksRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class TasksUpdated extends TasksEvent {
  final List<TaskEntity> tasks;

  const TasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class AddTaskRequested extends TasksEvent {
  final TaskEntity task;

  const AddTaskRequested(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskRequested extends TasksEvent {
  final TaskEntity task;

  const UpdateTaskRequested(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskRequested extends TasksEvent {
  final String userId;
  final String taskId;

  const DeleteTaskRequested({required this.userId, required this.taskId});

  @override
  List<Object?> get props => [userId, taskId];
}

class ToggleTaskCompletionRequested extends TasksEvent {
  final String userId;
  final String taskId;
  final bool isCompleted;

  const ToggleTaskCompletionRequested({
    required this.userId,
    required this.taskId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [userId, taskId, isCompleted];
}

class FilterCategoryChanged extends TasksEvent {
  final TaskFilterCategory category;

  const FilterCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class SortOptionChanged extends TasksEvent {
  final TaskSortOption sortOption;

  const SortOptionChanged(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

class SearchQueryChanged extends TasksEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectedGroupChanged extends TasksEvent {
  final String? groupId; // null means 'All Groups'

  const SelectedGroupChanged(this.groupId);

  @override
  List<Object?> get props => [groupId];
}
