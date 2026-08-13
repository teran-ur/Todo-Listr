import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failures.dart';
import '../../features/settings/data/models/user_settings_model.dart';

class FirestoreSettingsService {
  final FirebaseFirestore _firestore;

  FirestoreSettingsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<UserSettingsModel> watchSettings(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data()?['settings'] == null) {
        return const UserSettingsModel();
      }
      return UserSettingsModel.fromMap(
        snapshot.data()!['settings'] as Map<String, dynamic>,
      );
    });
  }

  Future<UserSettingsModel> getSettings(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();
      if (!snapshot.exists || snapshot.data()?['settings'] == null) {
        return const UserSettingsModel();
      }
      return UserSettingsModel.fromMap(
        snapshot.data()!['settings'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw ServerFailure('Failed to fetch settings from server: ${e.toString()}');
    }
  }

  Future<void> saveSettings(String userId, UserSettingsModel settings) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'settings': settings.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw ServerFailure('Failed to save settings to server: ${e.toString()}');
    }
  }
}
