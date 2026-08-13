import 'package:flutter/material.dart';
import 'app/app.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'services/auth/firebase_auth_service.dart';
import 'services/remote_storage/firestore_user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate Services & Repository
  final authService = FirebaseAuthService();
  final userService = FirestoreUserService();
  final authRepository = AuthRepositoryImpl(
    authService: authService,
    userService: userService,
  );

  runApp(ToDoApp(authRepository: authRepository));
}
