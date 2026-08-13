import 'package:equatable/equatable.dart';
import '../../domain/entities/sync_status.dart';

class SyncBlocState extends Equatable {
  final SyncStatusEntity status;

  const SyncBlocState({
    this.status = const SyncStatusEntity(
      state: SyncState.idle,
      pendingQueueLength: 0,
    ),
  });

  SyncBlocState copyWith({SyncStatusEntity? status}) {
    return SyncBlocState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}
