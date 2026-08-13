import 'package:equatable/equatable.dart';
import '../../domain/entities/user_settings.dart';

class SettingsState extends Equatable {
  final UserSettingsEntity settings;
  final bool isLoading;

  const SettingsState({
    this.settings = const UserSettingsEntity(),
    this.isLoading = false,
  });

  SettingsState copyWith({
    UserSettingsEntity? settings,
    bool? isLoading,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading];
}
