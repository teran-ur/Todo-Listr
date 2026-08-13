import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class WatchSettings {
  final SettingsRepository repository;

  WatchSettings(this.repository);

  Stream<UserSettingsEntity> call(String userId) {
    return repository.watchSettings(userId);
  }
}
