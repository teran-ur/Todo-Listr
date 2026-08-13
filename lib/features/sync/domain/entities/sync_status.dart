enum SyncState { idle, syncing, success, offline, error }

/// Domain entity representing real-time synchronization state
class SyncStatusEntity {
  final SyncState state;
  final int pendingQueueLength;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const SyncStatusEntity({
    required this.state,
    required this.pendingQueueLength,
    this.lastSyncedAt,
    this.errorMessage,
  });
}
