import 'package:equatable/equatable.dart';
import '../../domain/entities/sync_status.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class StartAutoSyncRequested extends SyncEvent {
  final String userId;

  const StartAutoSyncRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SyncStatusUpdated extends SyncEvent {
  final SyncStatusEntity status;

  const SyncStatusUpdated(this.status);

  @override
  List<Object?> get props => [status];
}

class TriggerManualSyncRequested extends SyncEvent {
  final String userId;

  const TriggerManualSyncRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class StopAutoSyncRequested extends SyncEvent {}
