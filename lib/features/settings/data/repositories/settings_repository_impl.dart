import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/user_settings_model.dart';
import '../../../../services/local_storage/local_settings_service.dart';
import '../../../../services/remote_storage/firestore_settings_service.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalSettingsService _localSettingsService;
  final FirestoreSettingsService _remoteSettingsService;

  SettingsRepositoryImpl({
    required LocalSettingsService localSettingsService,
    required FirestoreSettingsService remoteSettingsService,
  })  : _localSettingsService = localSettingsService,
        _remoteSettingsService = remoteSettingsService;

  @override
  Stream<UserSettingsEntity> watchSettings(String userId) {
    return _localSettingsService.watchSettings(userId);
  }

  @override
  Future<UserSettingsEntity> getSettings(String userId) {
    return _localSettingsService.getSettings(userId);
  }

  @override
  Future<void> updateSettings(String userId, UserSettingsEntity settings) async {
    final model = UserSettingsModel.fromEntity(settings);
    await _localSettingsService.saveSettings(userId, model);
    try {
      await _remoteSettingsService.saveSettings(userId, model);
    } catch (_) {}
  }
}
