import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/settings/domain/entities/user_settings.dart';
import 'package:todo_app/features/settings/domain/usecases/update_settings.dart';
import 'package:todo_app/features/settings/domain/usecases/watch_settings.dart';
import 'package:todo_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:todo_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:todo_app/features/settings/presentation/bloc/settings_state.dart';

class MockWatchSettings extends Mock implements WatchSettings {}
class MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

void main() {
  late MockWatchSettings mockWatchSettings;
  late MockUpdateSettingsUseCase mockUpdateSettings;
  late StreamController<UserSettingsEntity> settingsStreamController;

  const tSettings = UserSettingsEntity(
    themeMode: AppThemeMode.dark,
    accentColorHex: '#4CAF50',
    uiDensity: UiDensity.spacious,
  );

  setUp(() {
    mockWatchSettings = MockWatchSettings();
    mockUpdateSettings = MockUpdateSettingsUseCase();
    settingsStreamController = StreamController<UserSettingsEntity>.broadcast();

    registerFallbackValue(const UpdateSettingsParams(
      userId: 'user-1',
      settings: UserSettingsEntity(),
    ));

    when(() => mockWatchSettings('user-1'))
        .thenAnswer((_) => settingsStreamController.stream);
  });

  tearDown(() {
    settingsStreamController.close();
  });

  blocTest<SettingsBloc, SettingsState>(
    'emits updated SettingsState when SettingsUpdated is received',
    build: () => SettingsBloc(
      watchSettings: mockWatchSettings,
      updateSettings: mockUpdateSettings,
    ),
    act: (bloc) async {
      bloc.add(const LoadSettingsRequested('user-1'));
      await Future.delayed(const Duration(milliseconds: 10));
      settingsStreamController.add(tSettings);
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      const SettingsState(isLoading: true),
      const SettingsState(settings: tSettings, isLoading: false),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'updates themeMode when ChangeThemeModeRequested is emitted',
    build: () {
      when(() => mockUpdateSettings(any())).thenAnswer((_) async {});
      return SettingsBloc(
        watchSettings: mockWatchSettings,
        updateSettings: mockUpdateSettings,
      );
    },
    act: (bloc) => bloc.add(const ChangeThemeModeRequested(
      userId: 'user-1',
      themeMode: AppThemeMode.dark,
    )),
    expect: () => [
      const SettingsState(settings: UserSettingsEntity(themeMode: AppThemeMode.dark)),
    ],
  );
}
