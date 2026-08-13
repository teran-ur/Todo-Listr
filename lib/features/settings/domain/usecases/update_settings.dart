import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettingsParams extends Equatable {
  final String userId;
  final UserSettingsEntity settings;

  const UpdateSettingsParams({required this.userId, required this.settings});

  @override
  List<Object?> get props => [userId, settings];
}

class UpdateSettingsUseCase implements UseCase<void, UpdateSettingsParams> {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  @override
  Future<void> call(UpdateSettingsParams params) {
    return repository.updateSettings(params.userId, params.settings);
  }
}
