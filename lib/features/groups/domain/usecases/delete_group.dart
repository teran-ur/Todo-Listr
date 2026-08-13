import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_group_repository.dart';

class DeleteGroupParams extends Equatable {
  final String userId;
  final String groupId;

  const DeleteGroupParams({required this.userId, required this.groupId});

  @override
  List<Object?> get props => [userId, groupId];
}

class DeleteGroupUseCase implements UseCase<void, DeleteGroupParams> {
  final TaskGroupRepository repository;

  DeleteGroupUseCase(this.repository);

  @override
  Future<void> call(DeleteGroupParams params) {
    return repository.deleteGroup(params.userId, params.groupId);
  }
}
