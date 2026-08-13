import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_group.dart';
import '../repositories/task_group_repository.dart';

class ReorderGroupsParams extends Equatable {
  final String userId;
  final List<TaskGroupEntity> groups;

  const ReorderGroupsParams({required this.userId, required this.groups});

  @override
  List<Object?> get props => [userId, groups];
}

class ReorderGroupsUseCase implements UseCase<void, ReorderGroupsParams> {
  final TaskGroupRepository repository;

  ReorderGroupsUseCase(this.repository);

  @override
  Future<void> call(ReorderGroupsParams params) {
    return repository.reorderGroups(params.userId, params.groups);
  }
}
