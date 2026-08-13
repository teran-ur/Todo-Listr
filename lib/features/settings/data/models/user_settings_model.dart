import '../../domain/entities/user_settings.dart';

class UserSettingsModel extends UserSettingsEntity {
  const UserSettingsModel({
    super.themeMode,
    super.accentColorHex,
    super.uiDensity,
    super.textScaleFactor,
  });

  factory UserSettingsModel.fromEntity(UserSettingsEntity entity) {
    return UserSettingsModel(
      themeMode: entity.themeMode,
      accentColorHex: entity.accentColorHex,
      uiDensity: entity.uiDensity,
      textScaleFactor: entity.textScaleFactor,
    );
  }

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == map['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      accentColorHex: map['accentColorHex'] as String? ?? '#6750A4',
      uiDensity: UiDensity.values.firstWhere(
        (e) => e.name == map['uiDensity'],
        orElse: () => UiDensity.comfortable,
      ),
      textScaleFactor: (map['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'accentColorHex': accentColorHex,
      'uiDensity': uiDensity.name,
      'textScaleFactor': textScaleFactor,
    };
  }
}
