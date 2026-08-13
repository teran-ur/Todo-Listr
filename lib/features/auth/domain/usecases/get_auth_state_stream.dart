import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateStream {
  final AuthRepository repository;

  GetAuthStateStream(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}
