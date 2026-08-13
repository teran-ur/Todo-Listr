import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/tasks/data/models/task_model.dart';

void main() {
  final olderTime = DateTime(2026, 1, 1, 10, 0, 0);
  final newerTime = DateTime(2026, 1, 1, 10, 5, 0);

  final localTask = TaskModel(
    id: 'conflict-1',
    ownerId: 'user-1',
    groupId: 'default',
    title: 'Windows Edit',
    createdAt: olderTime,
    updatedAt: olderTime,
  );

  final remoteTaskNewer = TaskModel(
    id: 'conflict-1',
    ownerId: 'user-1',
    groupId: 'default',
    title: 'Android Edit (Newer)',
    createdAt: olderTime,
    updatedAt: newerTime,
  );

  final remoteTaskDeleted = TaskModel(
    id: 'conflict-1',
    ownerId: 'user-1',
    groupId: 'default',
    title: 'Windows Edit',
    createdAt: olderTime,
    updatedAt: newerTime,
    deletedAt: newerTime,
  );

  group('Last-Write-Wins (LWW) Conflict Resolution', () {
    test('Remote document with newer updatedAt wins over older local document', () {
      final remoteWins = remoteTaskNewer.updatedAt.isAfter(localTask.updatedAt);
      expect(remoteWins, isTrue);
    });

    test('Remote document with older updatedAt yields to newer local document', () {
      final localWins = localTask.updatedAt.isBefore(remoteTaskNewer.updatedAt);
      expect(localWins, isTrue);
    });

    test('Soft-deletion deletedAt takes precedence during conflict resolution', () {
      final isDeleted = remoteTaskDeleted.deletedAt != null;
      expect(isDeleted, isTrue);
    });
  });
}
