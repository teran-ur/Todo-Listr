import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/sync/domain/entities/sync_queue_item.dart';
import 'package:todo_app/features/tasks/data/models/task_model.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/services/local_storage/local_task_service.dart';
import 'package:todo_app/services/local_storage/sync_queue_service.dart';

void main() {
  late LocalTaskService localTaskService;
  late SyncQueueService syncQueueService;

  final tTaskModel = TaskModel(
    id: 'off-1',
    ownerId: 'user-offline',
    groupId: 'default',
    title: 'Offline Created Task',
    priority: TaskPriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    syncQueueService = SyncQueueService();
    localTaskService = LocalTaskService(syncQueueService: syncQueueService);
  });

  tearDown(() {
    localTaskService.dispose();
    syncQueueService.dispose();
  });

  test('offline task creation saves task locally and enqueues sync operation', () async {
    await localTaskService.saveTask(tTaskModel);

    final tasks = await localTaskService.getTasks('user-offline');
    expect(tasks.length, 1);
    expect(tasks.first.title, 'Offline Created Task');

    final queue = await syncQueueService.getPendingQueue('user-offline');
    expect(queue.length, 1);
    expect(queue.first.entityId, 'off-1');
    expect(queue.first.operation, SyncOperation.create);
  });

  test('offline task deletion soft-deletes task and enqueues delete sync operation', () async {
    await localTaskService.saveTask(tTaskModel);
    await localTaskService.deleteTask('user-offline', 'off-1');

    final tasks = await localTaskService.getTasks('user-offline');
    expect(tasks.isEmpty, isTrue);

    final queue = await syncQueueService.getPendingQueue('user-offline');
    expect(queue.length, 2); // 1 create + 1 delete
    expect(queue.last.operation, SyncOperation.delete);
  });
}
