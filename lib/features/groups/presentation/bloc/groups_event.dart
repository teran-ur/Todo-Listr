import 'package:equatable/equatable.dart';
import '../../domain/entities/task_group.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupsRequested extends GroupsEvent {
  final String userId;

  const LoadGroupsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GroupsUpdated extends GroupsEvent {
  final List<TaskGroupEntity> groups;

  const GroupsUpdated(this.groups);

  @override
  List<Object?> get props => [groups];
}

class AddGroupRequested extends GroupsEvent {
  final TaskGroupEntity group;

  const AddGroupRequested(this.group);

  @override
  List<Object?> get props => [group];
}

class UpdateGroupRequested extends GroupsEvent {
  final TaskGroupEntity group;

  const UpdateGroupRequested(this.group);

  @override
  List<Object?> get props => [group];
}

class DeleteGroupRequested extends GroupsEvent {
  final String userId;
  final String groupId;

  const DeleteGroupRequested({required this.userId, required this.groupId});

  @override
  List<Object?> get props => [userId, groupId];
}

class SelectGroupEvent extends GroupsEvent {
  final String? groupId; // null means 'All Tasks'

  const SelectGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class ReorderGroupsRequested extends GroupsEvent {
  final String userId;
  final List<TaskGroupEntity> groups;

  const ReorderGroupsRequested({required this.userId, required this.groups});

  @override
  List<Object?> get props => [userId, groups];
}
