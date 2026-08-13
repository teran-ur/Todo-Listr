import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_settings.dart';
import '../../domain/usecases/watch_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final WatchSettings _watchSettings;
  final UpdateSettingsUseCase _updateSettings;
  StreamSubscription? _settingsSubscription;

  SettingsBloc({
    required WatchSettings watchSettings,
    required UpdateSettingsUseCase updateSettings,
  })  : _watchSettings = watchSettings,
        _updateSettings = updateSettings,
        super(const SettingsState()) {
    on<LoadSettingsRequested>(_onLoadSettingsRequested);
    on<SettingsUpdatedEvent>(_onSettingsUpdatedEvent);
    on<ChangeThemeModeRequested>(_onChangeThemeModeRequested);
    on<ChangeAccentColorRequested>(_onChangeAccentColorRequested);
    on<ChangeUiDensityRequested>(_onChangeUiDensityRequested);
  }

  void _onLoadSettingsRequested(
    LoadSettingsRequested event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(isLoading: true));
    _settingsSubscription?.cancel();
    _settingsSubscription = _watchSettings(event.userId).listen(
      (settings) => add(SettingsUpdatedEvent(settings)),
    );
  }

  void _onSettingsUpdatedEvent(
    SettingsUpdatedEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(settings: event.settings, isLoading: false));
  }

  Future<void> _onChangeThemeModeRequested(
    ChangeThemeModeRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final updated = state.settings.copyWith(themeMode: event.themeMode);
    emit(state.copyWith(settings: updated));
    try {
      await _updateSettings(UpdateSettingsParams(
        userId: event.userId,
        settings: updated,
      ));
    } catch (_) {}
  }

  Future<void> _onChangeAccentColorRequested(
    ChangeAccentColorRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final updated = state.settings.copyWith(accentColorHex: event.accentColorHex);
    emit(state.copyWith(settings: updated));
    try {
      await _updateSettings(UpdateSettingsParams(
        userId: event.userId,
        settings: updated,
      ));
    } catch (_) {}
  }

  Future<void> _onChangeUiDensityRequested(
    ChangeUiDensityRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final updated = state.settings.copyWith(uiDensity: event.uiDensity);
    emit(state.copyWith(settings: updated));
    try {
      await _updateSettings(UpdateSettingsParams(
        userId: event.userId,
        settings: updated,
      ));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}
