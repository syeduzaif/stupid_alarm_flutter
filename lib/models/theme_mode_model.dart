import 'package:flutter/foundation.dart';

/// App-wide notifier so a theme change from Settings applies immediately.
/// Seeded from storage in main() and updated by the settings dialog.
final ValueNotifier<AppThemeMode> appThemeModeNotifier =
    ValueNotifier(AppThemeMode.system);

enum AppThemeMode {
  light,
  dark,
  system;

  static AppThemeMode fromString(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  @override
  String toString() {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }
}
