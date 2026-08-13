import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failures.dart';
import '../../features/auth/data/models/user_model.dart';

/// Remote service handling user profile CRUD in Cloud Firestore (/users/{userId})
class FirestoreUserService {
  final FirebaseFirestore _firestore;

  FirestoreUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Ensures user profile document exists in Cloud Firestore upon login/registration
  Future<void> createUserProfile(UserModel user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        await docRef.set(user.toFirestoreMap());
      } else {
        await docRef.update({
          'lastLoginAt': Timestamp.fromDate(user.lastLoginAt),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw ServerFailure('Failed to sync user profile: ${e.toString()}');
    }
  }
}
