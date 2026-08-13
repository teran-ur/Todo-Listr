import '../../../../services/local_storage/local_group_service.dart';
import '../../../../services/local_storage/local_task_service.dart';
import '../../../../services/remote_storage/firestore_group_service.dart';
import '../../../../services/remote_storage/firestore_task_service.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../domain/entities/task_group.dart';
import '../../domain/repositories/task_group_repository.dart';
import '../models/task_group_model.dart';

class TaskGroupRepositoryImpl implements TaskGroupRepository {
  final LocalGroupService _localGroupService;
  final FirestoreGroupService _remoteGroupService;
  final LocalTaskService? _localTaskService;
  final FirestoreTaskService? _remoteTaskService;

  TaskGroupRepositoryImpl({
    required LocalGroupService localGroupService,
    required FirestoreGroupService remoteGroupService,
    LocalTaskService? localTaskService,
    FirestoreTaskService? remoteTaskService,
  })  : _localGroupService = localGroupService,
        _remoteGroupService = remoteGroupService,
        _localTaskService = localTaskService,
        _remoteTaskService = remoteTaskService;

  @override
  Stream<List<TaskGroupEntity>> watchGroups(String userId) {
    return _localGroupService.watchGroups(userId);
  }

  @override
  Future<List<TaskGroupEntity>> getGroups(String userId) async {
    return _localGroupService.getGroups(userId);
  }

  @override
  Future<void> createGroup(TaskGroupEntity group) async {
    final model = TaskGroupModel.fromEntity(group);
    await _localGroupService.saveGroup(model, isUpdate: false);
    try {
      await _remoteGroupService.saveGroup(model);
    } catch (_) {}
  }

  @override
  Future<void> updateGroup(TaskGroupEntity group) async {
    final updated = group.copyWith(updatedAt: DateTime.now());
    final model = TaskGroupModel.fromEntity(updated);
    await _localGroupService.saveGroup(model, isUpdate: true);
    try {
      await _remoteGroupService.saveGroup(model);
    } catch (_) {}
  }

  @override
  Future<void> deleteGroup(String userId, String groupId) async {
    final localTasks = _localTaskService;
    final remoteTasks = _remoteTaskService;

    // Reassign orphan tasks belonging to deleted group to 'default'
    if (localTasks != null) {
      final tasks = await localTasks.getTasks(userId);
      final orphanTasks = tasks.where((t) => t.groupId == groupId);
      for (final orphan in orphanTasks) {
        final reassigned = TaskModel.fromEntity(
          orphan.copyWith(groupId: 'default', updatedAt: DateTime.now()),
        );
        await localTasks.saveTask(reassigned, isUpdate: true);
        if (remoteTasks != null) {
          try {
            await remoteTasks.saveTask(reassigned);
          } catch (_) {}
        }
      }
    }

    // Perform group soft delete
    await _localGroupService.deleteGroup(userId, groupId);
    try {
      await _remoteGroupService.deleteGroup(userId, groupId);
    } catch (_) {}
  }

  @override
  Future<void> reorderGroups(String userId, List<TaskGroupEntity> groups) async {
    for (int i = 0; i < groups.length; i++) {
      final reordered = groups[i].copyWith(
        sortOrder: i.toDouble(),
        updatedAt: DateTime.now(),
      );
      final model = TaskGroupModel.fromEntity(reordered);
      await _localGroupService.saveGroup(model, isUpdate: true);
      try {
        await _remoteGroupService.saveGroup(model);
      } catch (_) {}
    }
  }
}
