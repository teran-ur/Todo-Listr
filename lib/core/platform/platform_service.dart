/// Abstract contract for platform-specific capabilities (e.g. Window controls, native alerts)
abstract class PlatformService {
  /// Unique identifier of current OS
  String get operatingSystem;

  /// System initialization hook for platform extensions
  Future<void> initialize();

  /// Platform-specific path for storing offline cache
  Future<String> getLocalStoragePath();
}

/// Fallback standard implementation of PlatformService
class DefaultPlatformService implements PlatformService {
  @override
  String get operatingSystem => 'Generic';

  @override
  Future<void> initialize() async {
    // No-op for standard initialization
  }

  @override
  Future<String> getLocalStoragePath() async {
    return './storage';
  }
}
