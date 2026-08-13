import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../services/auth/firebase_auth_service.dart';
import '../../../../services/remote_storage/firestore_user_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreUserService _userService;

  AuthRepositoryImpl({
    required FirebaseAuthService authService,
    required FirestoreUserService userService,
  })  : _authService = authService,
        _userService = userService;

  @override
  Stream<UserEntity?> get authStateChanges => _authService.authStateChanges;

  @override
  UserEntity? get currentUser => _authService.currentUser;

  @override
  Future<UserEntity> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final userModel = await _authService.loginWithEmailAndPassword(email, password);
    try {
      await _userService.createUserProfile(userModel);
    } catch (_) {
      // Profile sync error ignored during offline or restricted network mode
    }
    return userModel;
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    final userModel = await _authService.registerWithEmailAndPassword(
      email,
      password,
      displayName: displayName,
    );
    try {
      await _userService.createUserProfile(userModel);
    } catch (_) {
      // Profile sync error ignored during offline or restricted network mode
    }
    return userModel;
  }

  @override
  Future<void> logout() {
    return _authService.logout();
  }
}
