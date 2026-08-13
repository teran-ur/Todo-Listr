import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  final String displayName;
  final String email;
  final String password;
  final String confirmPassword;
  final RegisterStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const RegisterState({
    this.displayName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = RegisterStatus.initial,
    this.user,
    this.errorMessage,
  });

  RegisterState copyWith({
    String? displayName,
    String? email,
    String? password,
    String? confirmPassword,
    RegisterStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return RegisterState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        email,
        password,
        confirmPassword,
        status,
        user,
        errorMessage,
      ];
}
