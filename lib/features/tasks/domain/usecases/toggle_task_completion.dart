import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class ToggleTaskCompletionParams extends Equatable {
  final String userId;
  final String taskId;
  final bool isCompleted;

  const ToggleTaskCompletionParams({
    required this.userId,
    required this.taskId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [userId, taskId, isCompleted];
}

class ToggleTaskCompletionUseCase
    implements UseCase<void, ToggleTaskCompletionParams> {
  final TaskRepository repository;

  ToggleTaskCompletionUseCase(this.repository);

  @override
  Future<void> call(ToggleTaskCompletionParams params) {
    return repository.toggleTaskCompletion(
      params.userId,
      params.taskId,
      params.isCompleted,
    );
  }
}
