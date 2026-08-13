import '../entities/user.dart';

/// Domain contract for Authentication operations
abstract class AuthRepository {
  /// Stream broadcasting authentication state changes
  Stream<UserEntity?> get authStateChanges;

  /// Currently logged in user entity if authenticated
  UserEntity? get currentUser;

  /// Login with email and password
  Future<UserEntity> loginWithEmailAndPassword(String email, String password);

  /// Register new account with email and password
  Future<UserEntity> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  });

  /// Logout current user
  Future<void> logout();
}
