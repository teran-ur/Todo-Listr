import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/usecases/usecase.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/domain/usecases/get_auth_state_stream.dart';
import 'package:todo_app/features/auth/domain/usecases/logout_user.dart';
import 'package:todo_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todo_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:todo_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockGetAuthStateStream extends Mock implements GetAuthStateStream {}
class MockLogoutUser extends Mock implements LogoutUser {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockGetAuthStateStream mockGetAuthStateStream;
  late MockLogoutUser mockLogoutUser;
  late StreamController<UserEntity?> authStreamController;

  final tUser = UserEntity(
    uid: '123',
    email: 'user@example.com',
    createdAt: DateTime(2026, 1, 1),
    lastLoginAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockGetAuthStateStream = MockGetAuthStateStream();
    mockLogoutUser = MockLogoutUser();
    authStreamController = StreamController<UserEntity?>.broadcast();

    registerFallbackValue(const NoParams());

    when(() => mockGetAuthStateStream.call())
        .thenAnswer((_) => authStreamController.stream);
  });

  tearDown(() {
    authStreamController.close();
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Authenticated] when currentUser stream emits on AuthCheckRequested',
    build: () {
      return AuthBloc(
        authRepository: mockAuthRepository,
        getAuthStateStream: mockGetAuthStateStream,
        logoutUser: mockLogoutUser,
      );
    },
    act: (bloc) async {
      bloc.add(AuthCheckRequested());
      await Future.delayed(const Duration(milliseconds: 10));
      authStreamController.add(tUser);
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      AuthLoading(),
      Authenticated(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] when currentUser stream emits null on AuthCheckRequested',
    build: () {
      return AuthBloc(
        authRepository: mockAuthRepository,
        getAuthStateStream: mockGetAuthStateStream,
        logoutUser: mockLogoutUser,
      );
    },
    act: (bloc) async {
      bloc.add(AuthCheckRequested());
      await Future.delayed(const Duration(milliseconds: 10));
      authStreamController.add(null);
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      AuthLoading(),
      Unauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] on AuthLogoutRequested',
    build: () {
      when(() => mockLogoutUser.call(any())).thenAnswer((_) async {});
      return AuthBloc(
        authRepository: mockAuthRepository,
        getAuthStateStream: mockGetAuthStateStream,
        logoutUser: mockLogoutUser,
      );
    },
    act: (bloc) => bloc.add(AuthLogoutRequested()),
    expect: () => [
      AuthLoading(),
      Unauthenticated(),
    ],
  );
}
