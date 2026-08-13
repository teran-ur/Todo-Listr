import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/sync/sync_service.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncBlocState> {
  final SyncService _syncService;
  StreamSubscription? _syncSubscription;

  SyncBloc({required SyncService syncService})
      : _syncService = syncService,
        super(const SyncBlocState()) {
    on<StartAutoSyncRequested>(_onStartAutoSyncRequested);
    on<SyncStatusUpdated>(_onSyncStatusUpdated);
    on<TriggerManualSyncRequested>(_onTriggerManualSyncRequested);
    on<StopAutoSyncRequested>(_onStopAutoSyncRequested);

    _syncSubscription = _syncService.statusStream.listen(
      (status) => add(SyncStatusUpdated(status)),
    );
  }

  void _onStartAutoSyncRequested(
    StartAutoSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) {
    _syncService.startAutoSync(userId: event.userId);
  }

  void _onSyncStatusUpdated(
    SyncStatusUpdated event,
    Emitter<SyncBlocState> emit,
  ) {
    emit(state.copyWith(status: event.status));
  }

  Future<void> _onTriggerManualSyncRequested(
    TriggerManualSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _syncService.triggerSync(userId: event.userId);
  }

  void _onStopAutoSyncRequested(
    StopAutoSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) {
    _syncService.stopAutoSync();
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    return super.close();
  }
}
