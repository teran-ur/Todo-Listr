import '../entities/task_group.dart';
import '../repositories/task_group_repository.dart';

class WatchGroups {
  final TaskGroupRepository repository;

  WatchGroups(this.repository);

  Stream<List<TaskGroupEntity>> call(String userId) {
    return repository.watchGroups(userId);
  }
}
