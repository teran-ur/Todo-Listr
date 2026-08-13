import '../../features/sync/domain/entities/sync_status.dart';

/// Contract for background synchronization engine
abstract class SyncService {
  /// Stream providing live sync state to UI
  Stream<SyncStatusEntity> get statusStream;

  /// Trigger manual synchronization process
  Future<void> triggerSync({required String userId});

  /// Start real-time background listener
  void startAutoSync({required String userId});

  /// Pause background listener
  void stopAutoSync();
}
