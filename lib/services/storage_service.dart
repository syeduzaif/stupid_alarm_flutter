import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_mode_model.dart';
import '../constants/app_constants.dart';

/// Service to manage app-wide storage and preferences
class StorageService {
  static StorageService? _instance;

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// Get theme mode
  Future<AppThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? themeMode = prefs.getString(AppConstants.keyThemeMode);
      
      if (themeMode == null) {
        return AppThemeMode.system;
      }
      
      return AppThemeMode.fromString(themeMode);
    } catch (e) {
      return AppThemeMode.system;
    }
  }

  /// Set theme mode
  Future<bool> setThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(AppConstants.keyThemeMode, themeMode.toString());
    } catch (e) {
      return false;
    }
  }

  /// Get default sound
  Future<String> getDefaultSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.keyDefaultSound) ?? 'default';
    } catch (e) {
      return 'default';
    }
  }

  /// Set default sound
  Future<bool> setDefaultSound(String sound) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(AppConstants.keyDefaultSound, sound);
    } catch (e) {
      return false;
    }
  }

  /// Get vibrate setting
  Future<bool> getVibrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.keyVibrate) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Set vibrate setting
  Future<bool> setVibrate(bool vibrate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(AppConstants.keyVibrate, vibrate);
    } catch (e) {
      return false;
    }
  }

  /// Get smart mode setting
  Future<bool> getSmartMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.keySmartMode) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Set smart mode setting
  Future<bool> setSmartMode(bool smartMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(AppConstants.keySmartMode, smartMode);
    } catch (e) {
      return false;
    }
  }
}
