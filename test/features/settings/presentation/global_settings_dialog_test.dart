import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/settings/domain/entities/user_settings.dart';
import 'package:todo_app/features/settings/domain/usecases/update_settings.dart';
import 'package:todo_app/features/settings/domain/usecases/watch_settings.dart';
import 'package:todo_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:todo_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:todo_app/features/settings/presentation/widgets/global_settings_dialog.dart';

class MockWatchSettings extends Mock implements WatchSettings {}
class MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

void main() {
  late MockWatchSettings mockWatchSettings;
  late MockUpdateSettingsUseCase mockUpdateSettings;

  setUp(() {
    mockWatchSettings = MockWatchSettings();
    mockUpdateSettings = MockUpdateSettingsUseCase();

    when(() => mockWatchSettings('user-100'))
        .thenAnswer((_) => Stream.value(const UserSettingsEntity()));
  });

  testWidgets('GlobalSettingsDialog displays theme mode and density options',
      (tester) async {
    final bloc = SettingsBloc(
      watchSettings: mockWatchSettings,
      updateSettings: mockUpdateSettings,
    )..add(const LoadSettingsRequested('user-100'));

    await tester.pumpWidget(
      BlocProvider<SettingsBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => BlocProvider<SettingsBloc>.value(
                      value: bloc,
                      child: const GlobalSettingsDialog(userId: 'user-100'),
                    ),
                  );
                },
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('global_settings_dialog')), findsOneWidget);
    expect(find.text('Global Appearance Settings'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('Global Accent Color'), findsOneWidget);
    expect(find.text('UI Spacing & Density'), findsOneWidget);
  });
}
