import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_user.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUser registerUser;

  RegisterCubit({required this.registerUser}) : super(RegisterInitial());

  Future<void> register(
    String email,
    String password, {
    String? displayName,
  }) async {
    emit(RegisterLoading());
    try {
      await registerUser(RegisterParams(
        email: email,
        password: password,
        displayName: displayName,
      ));
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
