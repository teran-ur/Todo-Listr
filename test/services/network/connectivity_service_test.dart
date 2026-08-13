import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/network/connectivity_service.dart';

void main() {
  late ConnectivityService connectivityService;

  setUp(() {
    connectivityService = ConnectivityService(initialIsOnline: true);
  });

  tearDown(() {
    connectivityService.dispose();
  });

  test('ConnectivityService initializes with online status and emits updates', () async {
    expect(connectivityService.isOnline, isTrue);

    final expectation = expectLater(
      connectivityService.onConnectivityChanged,
      emitsInOrder([false, true]),
    );

    connectivityService.setOnlineStatus(false);
    expect(connectivityService.isOnline, isFalse);

    connectivityService.setOnlineStatus(true);
    expect(connectivityService.isOnline, isTrue);

    await expectation;
  });
}
