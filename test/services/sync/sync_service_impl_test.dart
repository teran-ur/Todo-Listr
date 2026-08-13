import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/sync/domain/entities/sync_queue_item.dart';
import 'package:todo_app/features/sync/domain/entities/sync_status.dart';
import 'package:todo_app/features/tasks/data/models/task_model.dart';
import 'package:todo_app/services/local_storage/local_group_service.dart';
import 'package:todo_app/services/local_storage/local_settings_service.dart';
import 'package:todo_app/services/local_storage/local_task_service.dart';
import 'package:todo_app/services/local_storage/sync_queue_service.dart';
import 'package:todo_app/services/network/connectivity_service.dart';
import 'package:todo_app/services/remote_storage/firestore_group_service.dart';
import 'package:todo_app/services/remote_storage/firestore_settings_service.dart';
import 'package:todo_app/services/remote_storage/firestore_task_service.dart';
import 'package:todo_app/services/sync/sync_service_impl.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}
class MockSyncQueueService extends Mock implements SyncQueueService {}
class MockFirestoreTaskService extends Mock implements FirestoreTaskService {}
class MockFirestoreGroupService extends Mock implements FirestoreGroupService {}
class MockFirestoreSettingsService extends Mock implements FirestoreSettingsService {}
class MockLocalTaskService extends Mock implements LocalTaskService {}
class MockLocalGroupService extends Mock implements LocalGroupService {}
class MockLocalSettingsService extends Mock implements LocalSettingsService {}

void main() {
  late SyncServiceImpl syncService;
  late MockConnectivityService mockConnectivity;
  late MockSyncQueueService mockQueue;
  late MockFirestoreTaskService mockRemoteTasks;
  late MockFirestoreGroupService mockRemoteGroups;
  late MockFirestoreSettingsService mockRemoteSettings;
  late MockLocalTaskService mockLocalTasks;
  late MockLocalGroupService mockLocalGroups;
  late MockLocalSettingsService mockLocalSettings;

  final tQueueItem = SyncQueueItem(
    queueId: 'q-1',
    userId: 'user-sync',
    entityType: SyncEntityType.task,
    entityId: 'task-sync-1',
    operation: SyncOperation.create,
    payload: const {
      'id': 'task-sync-1',
      'ownerId': 'user-sync',
      'title': 'Sync Task',
    },
    timestamp: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockConnectivity = MockConnectivityService();
    mockQueue = MockSyncQueueService();
    mockRemoteTasks = MockFirestoreTaskService();
    mockRemoteGroups = MockFirestoreGroupService();
    mockRemoteSettings = MockFirestoreSettingsService();
    mockLocalTasks = MockLocalTaskService();
    mockLocalGroups = MockLocalGroupService();
    mockLocalSettings = MockLocalSettingsService();

    when(() => mockConnectivity.isOnline).thenReturn(true);
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value(true));

    when(() => mockRemoteTasks.watchTasks(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRemoteGroups.watchGroups(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRemoteSettings.watchSettings(any()))
        .thenAnswer((_) => const Stream.empty());

    syncService = SyncServiceImpl(
      connectivityService: mockConnectivity,
      syncQueueService: mockQueue,
      remoteTaskService: mockRemoteTasks,
      remoteGroupService: mockRemoteGroups,
      remoteSettingsService: mockRemoteSettings,
      localTaskService: mockLocalTasks,
      localGroupService: mockLocalGroups,
      localSettingsService: mockLocalSettings,
    );

    registerFallbackValue(TaskModel(
      id: 'task-sync-1',
      ownerId: 'user-sync',
      groupId: 'default',
      title: 'Sync Task',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  tearDown(() {
    syncService.dispose();
  });

  test('triggerSync processes queue items upstream when online', () async {
    when(() => mockQueue.getPendingQueue('user-sync'))
        .thenAnswer((_) async => [tQueueItem]);
    when(() => mockRemoteTasks.saveTask(any())).thenAnswer((_) async {});
    when(() => mockQueue.remove('q-1')).thenAnswer((_) async {});

    final expectation = expectLater(
      syncService.statusStream,
      emitsInOrder([
        isA<SyncStatusEntity>().having((s) => s.state, 'state', SyncState.syncing),
        isA<SyncStatusEntity>().having((s) => s.state, 'state', SyncState.success),
      ]),
    );

    await syncService.triggerSync(userId: 'user-sync');

    verify(() => mockRemoteTasks.saveTask(any())).called(1);
    verify(() => mockQueue.remove('q-1')).called(1);
    await expectation;
  });
}
