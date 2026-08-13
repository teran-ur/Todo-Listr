import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Stream<UserSettingsEntity> watchSettings(String userId);
  Future<UserSettingsEntity> getSettings(String userId);
  Future<void> updateSettings(String userId, UserSettingsEntity settings);
}
