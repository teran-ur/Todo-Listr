import 'dart:async';

/// Service monitoring device network connectivity (online/offline)
class ConnectivityService {
  bool _isOnline = true;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  ConnectivityService({bool initialIsOnline = true})
      : _isOnline = initialIsOnline;

  bool get isOnline => _isOnline;

  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Simulate or set online/offline network state
  void setOnlineStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _connectivityController.add(_isOnline);
    }
  }

  void dispose() {
    _connectivityController.close();
  }
}
