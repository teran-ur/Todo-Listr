import '../../../../core/usecases/usecase.dart';
import '../entities/task_group.dart';
import '../repositories/task_group_repository.dart';

class CreateGroupUseCase implements UseCase<void, TaskGroupEntity> {
  final TaskGroupRepository repository;

  CreateGroupUseCase(this.repository);

  @override
  Future<void> call(TaskGroupEntity group) {
    return repository.createGroup(group);
  }
}
