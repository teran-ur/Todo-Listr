import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase implements UseCase<void, TaskEntity> {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  @override
  Future<void> call(TaskEntity task) {
    return repository.createTask(task);
  }
}
