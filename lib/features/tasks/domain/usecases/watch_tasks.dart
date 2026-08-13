import '../entities/task.dart';
import '../repositories/task_repository.dart';

class WatchTasks {
  final TaskRepository repository;

  WatchTasks(this.repository);

  Stream<List<TaskEntity>> call(String userId) {
    return repository.watchTasks(userId);
  }
}
