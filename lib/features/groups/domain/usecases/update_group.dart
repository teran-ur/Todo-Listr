import '../../../../core/usecases/usecase.dart';
import '../entities/task_group.dart';
import '../repositories/task_group_repository.dart';

class UpdateGroupUseCase implements UseCase<void, TaskGroupEntity> {
  final TaskGroupRepository repository;

  UpdateGroupUseCase(this.repository);

  @override
  Future<void> call(TaskGroupEntity group) {
    return repository.updateGroup(group);
  }
}
