import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/register_user.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUser _registerUser;

  RegisterCubit({required RegisterUser registerUser})
      : _registerUser = registerUser,
        super(const RegisterState());

  void displayNameChanged(String displayName) {
    emit(state.copyWith(
      displayName: displayName,
      status: RegisterStatus.initial,
      errorMessage: null,
    ));
  }

  void emailChanged(String email) {
    emit(state.copyWith(
      email: email,
      status: RegisterStatus.initial,
      errorMessage: null,
    ));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(
      password: password,
      status: RegisterStatus.initial,
      errorMessage: null,
    ));
  }

  void confirmPasswordChanged(String confirmPassword) {
    emit(state.copyWith(
      confirmPassword: confirmPassword,
      status: RegisterStatus.initial,
      errorMessage: null,
    ));
  }

  Future<void> submitRegister() async {
    final email = state.email.trim();
    if (email.isEmpty || !email.contains('@')) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Please enter a valid email address.',
      ));
      return;
    }
    if (state.password.length < 6) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Password must be at least 6 characters.',
      ));
      return;
    }
    if (state.password != state.confirmPassword) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Passwords do not match.',
      ));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading, errorMessage: null));

    try {
      final user = await _registerUser(RegisterParams(
        email: email,
        password: state.password,
        displayName: state.displayName.trim().isEmpty ? null : state.displayName.trim(),
      ));
      emit(state.copyWith(status: RegisterStatus.success, user: user));
    } on Failure catch (e) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
