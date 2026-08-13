import 'package:flutter/foundation.dart';

/// Isolation utility to inspect runtime target platform cleanly
/// without duplicating operating system detection logic.
class PlatformInfo {
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static String get platformName {
    if (isWindows) return 'Windows';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    return defaultTargetPlatform.name;
  }
}
