import 'package:equatable/equatable.dart';

enum AppThemeMode { system, light, dark }

enum UiDensity { comfortable, compact, spacious }

class UserSettingsEntity extends Equatable {
  final AppThemeMode themeMode;
  final String accentColorHex;
  final UiDensity uiDensity;
  final double textScaleFactor;

  const UserSettingsEntity({
    this.themeMode = AppThemeMode.system,
    this.accentColorHex = '#6750A4',
    this.uiDensity = UiDensity.comfortable,
    this.textScaleFactor = 1.0,
  });

  UserSettingsEntity copyWith({
    AppThemeMode? themeMode,
    String? accentColorHex,
    UiDensity? uiDensity,
    double? textScaleFactor,
  }) {
    return UserSettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      uiDensity: uiDensity ?? this.uiDensity,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        accentColorHex,
        uiDensity,
        textScaleFactor,
      ];
}
