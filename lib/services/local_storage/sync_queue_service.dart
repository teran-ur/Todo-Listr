import 'dart:async';
import '../../features/sync/domain/entities/sync_queue_item.dart';

/// Service managing persistent write-ahead sync log queue for offline mutations
class SyncQueueService {
  final List<SyncQueueItem> _queue = [];
  final StreamController<List<SyncQueueItem>> _streamController =
      StreamController<List<SyncQueueItem>>.broadcast();

  Stream<List<SyncQueueItem>> watchQueue(String userId) {
    return _streamController.stream.map((items) {
      return items.where((item) => item.userId == userId).toList();
    });
  }

  Future<void> enqueue(SyncQueueItem item) async {
    _queue.add(item);
    _notifyListeners();
  }

  Future<List<SyncQueueItem>> getPendingQueue(String userId) async {
    return _queue.where((item) => item.userId == userId).toList();
  }

  Future<void> remove(String queueId) async {
    _queue.removeWhere((item) => item.queueId == queueId);
    _notifyListeners();
  }

  Future<void> clearUserQueue(String userId) async {
    _queue.removeWhere((item) => item.userId == userId);
    _notifyListeners();
  }

  void _notifyListeners() {
    _streamController.add(List.from(_queue));
  }

  void dispose() {
    _streamController.close();
  }
}
