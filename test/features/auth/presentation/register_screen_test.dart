import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/presentation/screens/register_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget buildSubject() {
    return RepositoryProvider<AuthRepository>.value(
      value: mockAuthRepository,
      child: const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  testWidgets('renders register screen fields and buttons', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('register_screen')), findsOneWidget);
    expect(find.byKey(const Key('register_email_input')), findsOneWidget);
    expect(find.byKey(const Key('register_password_input')), findsOneWidget);
    expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
  });
}
