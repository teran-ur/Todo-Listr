import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/auth/data/models/user_model.dart';
import 'package:todo_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:todo_app/services/auth/firebase_auth_service.dart';
import 'package:todo_app/services/remote_storage/firestore_user_service.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}
class MockFirestoreUserService extends Mock implements FirestoreUserService {}

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuthService mockAuthService;
  late MockFirestoreUserService mockUserService;

  final tUserModel = UserModel(
    uid: 'user-123',
    email: 'test@example.com',
    displayName: 'Test User',
    createdAt: DateTime(2026, 1, 1),
    lastLoginAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockAuthService = MockFirebaseAuthService();
    mockUserService = MockFirestoreUserService();
    repository = AuthRepositoryImpl(
      authService: mockAuthService,
      userService: mockUserService,
    );
  });

  group('loginWithEmailAndPassword', () {
    test('should return UserModel when login succeeds and create user profile', () async {
      when(() => mockAuthService.loginWithEmailAndPassword('test@example.com', 'password123'))
          .thenAnswer((_) async => tUserModel);
      when(() => mockUserService.createUserProfile(tUserModel))
          .thenAnswer((_) async {});

      final result = await repository.loginWithEmailAndPassword('test@example.com', 'password123');

      expect(result, tUserModel);
      verify(() => mockAuthService.loginWithEmailAndPassword('test@example.com', 'password123')).called(1);
      verify(() => mockUserService.createUserProfile(tUserModel)).called(1);
    });

    test('should rethrow AuthFailure when credentials are invalid', () async {
      when(() => mockAuthService.loginWithEmailAndPassword('wrong@example.com', 'wrongpass'))
          .thenThrow(const AuthFailure('Invalid credentials'));

      expect(
        () => repository.loginWithEmailAndPassword('wrong@example.com', 'wrongpass'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('registerWithEmailAndPassword', () {
    test('should register user and create profile document', () async {
      when(() => mockAuthService.registerWithEmailAndPassword(
            'new@example.com',
            'password123',
            displayName: 'New User',
          )).thenAnswer((_) async => tUserModel);
      when(() => mockUserService.createUserProfile(tUserModel))
          .thenAnswer((_) async {});

      final result = await repository.registerWithEmailAndPassword(
        'new@example.com',
        'password123',
        displayName: 'New User',
      );

      expect(result, tUserModel);
      verify(() => mockAuthService.registerWithEmailAndPassword(
            'new@example.com',
            'password123',
            displayName: 'New User',
          )).called(1);
      verify(() => mockUserService.createUserProfile(tUserModel)).called(1);
    });
  });

  group('logout', () {
    test('should invoke logout on FirebaseAuthService', () async {
      when(() => mockAuthService.logout()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockAuthService.logout()).called(1);
    });
  });
}
