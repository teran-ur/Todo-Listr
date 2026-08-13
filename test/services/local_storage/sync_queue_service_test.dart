import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/sync/domain/entities/sync_queue_item.dart';
import 'package:todo_app/services/local_storage/sync_queue_service.dart';

void main() {
  late SyncQueueService queueService;

  final tQueueItem = SyncQueueItem(
    queueId: 'q-100',
    userId: 'user-123',
    entityType: SyncEntityType.task,
    entityId: 'task-55',
    operation: SyncOperation.create,
    payload: const {'title': 'Offline Task'},
    timestamp: DateTime(2026, 1, 1),
  );

  setUp(() {
    queueService = SyncQueueService();
  });

  tearDown(() {
    queueService.dispose();
  });

  test('enqueue adds item to pending queue for specified user', () async {
    await queueService.enqueue(tQueueItem);

    final pending = await queueService.getPendingQueue('user-123');
    expect(pending.length, 1);
    expect(pending.first.queueId, 'q-100');
    expect(pending.first.payload['title'], 'Offline Task');
  });

  test('remove deletes processed item from queue', () async {
    await queueService.enqueue(tQueueItem);
    await queueService.remove('q-100');

    final pending = await queueService.getPendingQueue('user-123');
    expect(pending.isEmpty, isTrue);
  });
}
