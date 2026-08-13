import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failures.dart';
import '../../features/groups/data/models/task_group_model.dart';

/// Remote service interacting with Cloud Firestore (/users/{userId}/groups/{groupId})
class FirestoreGroupService {
  final FirebaseFirestore _firestore;

  FirestoreGroupService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<TaskGroupModel>> watchGroups(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('groups')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskGroupModel.fromFirestoreMap(doc.data()))
          .where((group) => group.deletedAt == null)
          .toList();
    });
  }

  Future<List<TaskGroupModel>> getGroups(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('groups')
          .get();
      return snapshot.docs
          .map((doc) => TaskGroupModel.fromFirestoreMap(doc.data()))
          .where((group) => group.deletedAt == null)
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch groups from server: ${e.toString()}');
    }
  }

  Future<void> saveGroup(TaskGroupModel group) async {
    try {
      await _firestore
          .collection('users')
          .doc(group.ownerId)
          .collection('groups')
          .doc(group.id)
          .set(group.toFirestoreMap(), SetOptions(merge: true));
    } catch (e) {
      throw ServerFailure('Failed to save group to server: ${e.toString()}');
    }
  }

  Future<void> deleteGroup(String userId, String groupId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('groups')
          .doc(groupId)
          .update({
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to delete group on server: ${e.toString()}');
    }
  }
}
