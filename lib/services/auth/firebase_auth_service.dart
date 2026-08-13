import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../core/error/failures.dart';
import '../../features/auth/data/models/user_model.dart';

/// Service wrapper isolating low-level Firebase Auth SDK calls
class FirebaseAuthService {
  final fb_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthService({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance;

  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  Future<UserModel> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthFailure('User authentication failed.');
      }
      return UserModel.fromFirebaseUser(credential.user!);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e), code: e.code);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  Future<UserModel> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Registration failed.');
      }

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      final updatedUser = _firebaseAuth.currentUser ?? user;
      return UserModel.fromFirebaseUser(updatedUser);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e), code: e.code);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthFailure('Failed to sign out: ${e.toString()}');
    }
  }

  String _mapFirebaseError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'invalid-email':
        return 'The provided email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
