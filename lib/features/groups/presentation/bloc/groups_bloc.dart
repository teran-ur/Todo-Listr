import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/delete_group.dart';
import '../../domain/usecases/reorder_groups.dart';
import '../../domain/usecases/update_group.dart';
import '../../domain/usecases/watch_groups.dart';
import 'groups_event.dart';
import 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final WatchGroups _watchGroups;
  final CreateGroupUseCase _createGroup;
  final UpdateGroupUseCase _updateGroup;
  final DeleteGroupUseCase _deleteGroup;
  final ReorderGroupsUseCase _reorderGroups;
  StreamSubscription? _groupsSubscription;

  GroupsBloc({
    required WatchGroups watchGroups,
    required CreateGroupUseCase createGroup,
    required UpdateGroupUseCase updateGroup,
    required DeleteGroupUseCase deleteGroup,
    required ReorderGroupsUseCase reorderGroups,
  })  : _watchGroups = watchGroups,
        _createGroup = createGroup,
        _updateGroup = updateGroup,
        _deleteGroup = deleteGroup,
        _reorderGroups = reorderGroups,
        super(GroupsInitial()) {
    on<LoadGroupsRequested>(_onLoadGroupsRequested);
    on<GroupsUpdated>(_onGroupsUpdated);
    on<AddGroupRequested>(_onAddGroupRequested);
    on<UpdateGroupRequested>(_onUpdateGroupRequested);
    on<DeleteGroupRequested>(_onDeleteGroupRequested);
    on<SelectGroupEvent>(_onSelectGroupEvent);
    on<ReorderGroupsRequested>(_onReorderGroupsRequested);
  }

  void _onLoadGroupsRequested(
    LoadGroupsRequested event,
    Emitter<GroupsState> emit,
  ) {
    emit(GroupsLoading());
    _groupsSubscription?.cancel();
    _groupsSubscription = _watchGroups(event.userId).listen(
      (groups) => add(GroupsUpdated(groups)),
      onError: (error) => add(const GroupsUpdated([])),
    );
  }

  void _onGroupsUpdated(
    GroupsUpdated event,
    Emitter<GroupsState> emit,
  ) {
    final currentSelectedId = state is GroupsLoaded
        ? (state as GroupsLoaded).selectedGroupId
        : null;

    emit(GroupsLoaded(
      allGroups: event.groups,
      selectedGroupId: currentSelectedId,
    ));
  }

  Future<void> _onAddGroupRequested(
    AddGroupRequested event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _createGroup(event.group);
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onUpdateGroupRequested(
    UpdateGroupRequested event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _updateGroup(event.group);
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onDeleteGroupRequested(
    DeleteGroupRequested event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _deleteGroup(DeleteGroupParams(
        userId: event.userId,
        groupId: event.groupId,
      ));
      if (state is GroupsLoaded) {
        final currentState = state as GroupsLoaded;
        if (currentState.selectedGroupId == event.groupId) {
          emit(currentState.copyWith(selectedGroupId: null));
        }
      }
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  void _onSelectGroupEvent(
    SelectGroupEvent event,
    Emitter<GroupsState> emit,
  ) {
    if (state is GroupsLoaded) {
      final currentState = state as GroupsLoaded;
      emit(currentState.copyWith(selectedGroupId: event.groupId));
    }
  }

  Future<void> _onReorderGroupsRequested(
    ReorderGroupsRequested event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _reorderGroups(ReorderGroupsParams(
        userId: event.userId,
        groups: event.groups,
      ));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
