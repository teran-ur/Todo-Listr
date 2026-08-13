import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTaskParams extends Equatable {
  final String userId;
  final String taskId;

  const DeleteTaskParams({required this.userId, required this.taskId});

  @override
  List<Object?> get props => [userId, taskId];
}

class DeleteTaskUseCase implements UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<void> call(DeleteTaskParams params) {
    return repository.deleteTask(params.userId, params.taskId);
  }
}
