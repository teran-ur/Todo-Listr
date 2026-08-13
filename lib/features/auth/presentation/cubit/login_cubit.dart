import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/login_user.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUser _loginUser;

  LoginCubit({required LoginUser loginUser})
      : _loginUser = loginUser,
        super(const LoginState());

  void emailChanged(String email) {
    emit(state.copyWith(email: email, status: LoginStatus.initial, errorMessage: null));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(password: password, status: LoginStatus.initial, errorMessage: null));
  }

  Future<void> submitLogin() async {
    if (state.email.trim().isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please enter your email address.',
      ));
      return;
    }
    if (state.password.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please enter your password.',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      final user = await _loginUser(LoginParams(
        email: state.email.trim(),
        password: state.password,
      ));
      emit(state.copyWith(status: LoginStatus.success, user: user));
    } on Failure catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
