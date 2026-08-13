import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failures.dart';
import '../../features/tasks/data/models/task_model.dart';

class FirestoreTaskService {
  final FirebaseFirestore _firestore;

  FirestoreTaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<TaskModel>> watchTasks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromFirestoreMap(doc.data()))
          .where((task) => task.deletedAt == null)
          .toList();
    });
  }

  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromFirestoreMap(doc.data()))
          .where((task) => task.deletedAt == null)
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch tasks from server: ${e.toString()}');
    }
  }

  Future<void> saveTask(TaskModel task) async {
    try {
      await _firestore
          .collection('users')
          .doc(task.ownerId)
          .collection('tasks')
          .doc(task.id)
          .set(task.toFirestoreMap(), SetOptions(merge: true));
    } catch (e) {
      throw ServerFailure('Failed to save task to server: ${e.toString()}');
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to delete task on server: ${e.toString()}');
    }
  }
}
