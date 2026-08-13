import 'package:equatable/equatable.dart';
import '../../domain/entities/task_group.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object?> get props => [];
}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<TaskGroupEntity> allGroups;
  final String? selectedGroupId; // null means 'All Tasks'

  const GroupsLoaded({
    required this.allGroups,
    this.selectedGroupId,
  });

  GroupsLoaded copyWith({
    List<TaskGroupEntity>? allGroups,
    String? selectedGroupId,
  }) {
    return GroupsLoaded(
      allGroups: allGroups ?? this.allGroups,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
    );
  }

  @override
  List<Object?> get props => [allGroups, selectedGroupId];
}

class GroupsError extends GroupsState {
  final String message;

  const GroupsError(this.message);

  @override
  List<Object?> get props => [message];
}
