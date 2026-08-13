import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/domain/usecases/login_user.dart';
import 'package:todo_app/features/auth/presentation/screens/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockLoginUser extends Mock implements LoginUser {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerFallbackValue(const LoginParams(email: 'test@example.com', password: 'password'));
  });

  Widget buildSubject() {
    return RepositoryProvider<AuthRepository>.value(
      value: mockAuthRepository,
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('renders login screen fields and buttons', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('login_screen')), findsOneWidget);
    expect(find.byKey(const Key('login_email_input')), findsOneWidget);
    expect(find.byKey(const Key('login_password_input')), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
  });

  testWidgets('displays validation error when login clicked with empty inputs', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email address.'), findsOneWidget);
  });
}
