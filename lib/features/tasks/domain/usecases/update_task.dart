import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase implements UseCase<void, TaskEntity> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<void> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}
