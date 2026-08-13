import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/settings/data/models/user_settings_model.dart';
import 'package:todo_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:todo_app/features/settings/domain/entities/user_settings.dart';
import 'package:todo_app/services/local_storage/local_settings_service.dart';
import 'package:todo_app/services/remote_storage/firestore_settings_service.dart';

class MockLocalSettingsService extends Mock implements LocalSettingsService {}
class MockFirestoreSettingsService extends Mock implements FirestoreSettingsService {}

void main() {
  late SettingsRepositoryImpl repository;
  late MockLocalSettingsService mockLocalSettingsService;
  late MockFirestoreSettingsService mockFirestoreSettingsService;

  const tSettings = UserSettingsEntity(
    themeMode: AppThemeMode.dark,
    accentColorHex: '#2196F3',
    uiDensity: UiDensity.compact,
  );

  final tSettingsModel = UserSettingsModel.fromEntity(tSettings);

  setUp(() {
    mockLocalSettingsService = MockLocalSettingsService();
    mockFirestoreSettingsService = MockFirestoreSettingsService();
    repository = SettingsRepositoryImpl(
      localSettingsService: mockLocalSettingsService,
      remoteSettingsService: mockFirestoreSettingsService,
    );

    registerFallbackValue(tSettingsModel);
  });

  group('updateSettings', () {
    test('saves settings locally and remotely for sync', () async {
      when(() => mockLocalSettingsService.saveSettings('user-1', tSettingsModel))
          .thenAnswer((_) async {});
      when(() => mockFirestoreSettingsService.saveSettings('user-1', tSettingsModel))
          .thenAnswer((_) async {});

      await repository.updateSettings('user-1', tSettings);

      verify(() => mockLocalSettingsService.saveSettings('user-1', tSettingsModel)).called(1);
      verify(() => mockFirestoreSettingsService.saveSettings('user-1', tSettingsModel)).called(1);
    });
  });

  group('watchSettings', () {
    test('emits settings stream from local storage', () async {
      when(() => mockLocalSettingsService.watchSettings('user-1'))
          .thenAnswer((_) => Stream.value(tSettingsModel));

      final stream = repository.watchSettings('user-1');

      expect(await stream.first, tSettingsModel);
    });
  });
}
