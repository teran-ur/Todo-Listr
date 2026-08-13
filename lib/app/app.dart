import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'router.dart';
import 'theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/settings/presentation/bloc/settings_event.dart';
import '../features/settings/presentation/bloc/settings_state.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_auth_state_stream.dart';
import '../features/auth/domain/usecases/logout_user.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/domain/usecases/watch_settings.dart';
import '../features/settings/domain/usecases/update_settings.dart';
import '../services/local_storage/local_settings_service.dart';
import '../services/local_storage/sync_queue_service.dart';
import '../services/remote_storage/firestore_settings_service.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';

class ToDoApp extends StatelessWidget {
  final AuthRepository authRepository;

  const ToDoApp({
    super.key,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    final syncQueueService = SyncQueueService();
    final localSettingsService = LocalSettingsService(syncQueueService: syncQueueService);
    final remoteSettingsService = FirestoreSettingsService();

    final settingsRepository = SettingsRepositoryImpl(
      localSettingsService: localSettingsService,
      remoteSettingsService: remoteSettingsService,
    );

    return RepositoryProvider<AuthRepository>.value(
      value: authRepository,
      child: RepositoryProvider<SettingsRepository>.value(
        value: settingsRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                authRepository: authRepository,
                getAuthStateStream: GetAuthStateStream(authRepository),
                logoutUser: LogoutUser(authRepository),
              )..add(AuthCheckRequested()),
            ),
            BlocProvider<SettingsBloc>(
              create: (context) => SettingsBloc(
                watchSettings: WatchSettings(settingsRepository),
                updateSettings: UpdateSettingsUseCase(settingsRepository),
              )..add(const LoadSettingsRequested('global')),
            ),
          ],
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final settings = state.settings;
              final themeMode = AppTheme.getThemeMode(settings.themeMode);

              return MaterialApp(
                title: 'Personal Task Manager',
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: AppTheme.buildTheme(
                  settings: settings,
                  brightness: Brightness.light,
                ),
                darkTheme: AppTheme.buildTheme(
                  settings: settings,
                  brightness: Brightness.dark,
                ),
                home: const AuthFlowHandler(),
              );
            },
          ),
        ),
      ),
    );
  }
}
