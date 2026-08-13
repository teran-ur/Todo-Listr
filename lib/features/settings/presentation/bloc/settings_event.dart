import 'package:equatable/equatable.dart';
import '../../domain/entities/user_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsRequested extends SettingsEvent {
  final String userId;

  const LoadSettingsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SettingsUpdatedEvent extends SettingsEvent {
  final UserSettingsEntity settings;

  const SettingsUpdatedEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ChangeThemeModeRequested extends SettingsEvent {
  final String userId;
  final AppThemeMode themeMode;

  const ChangeThemeModeRequested({required this.userId, required this.themeMode});

  @override
  List<Object?> get props => [userId, themeMode];
}

class ChangeAccentColorRequested extends SettingsEvent {
  final String userId;
  final String accentColorHex;

  const ChangeAccentColorRequested({required this.userId, required this.accentColorHex});

  @override
  List<Object?> get props => [userId, accentColorHex];
}

class ChangeUiDensityRequested extends SettingsEvent {
  final String userId;
  final UiDensity uiDensity;

  const ChangeUiDensityRequested({required this.userId, required this.uiDensity});

  @override
  List<Object?> get props => [userId, uiDensity];
}
