class AppConstants {
  // App Info
  static const String appName = 'Stupid Alarm';
  static const String appVersion = '1.0.0';

  // Spacing Constants
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Alarm Settings
  static const int defaultSnoozeDuration = 5; // minutes
  static const int defaultSnoozeLimit = 3;
  static const double tiltThreshold = 0.7; // Threshold for detecting tilt
  static const int tiltCheckDuration = 3; // seconds to hold tilt

  // Storage Keys
  static const String keyAlarms = 'alarms';
  static const String keyThemeMode = 'theme_mode';
  static const String keyDefaultSound = 'default_sound';
  static const String keyVibrate = 'vibrate';
  static const String keySmartMode = 'smart_mode';

  // Asset Paths
  static const String animationSplash = 'assets/animations/splash.json';
  static const String animationAlarm = 'assets/animations/alarm.json';
  static const String animationSleepy = 'assets/animations/sleepy.json';
  static const String soundDefaultAlarm = 'assets/sounds/default_alarm.mp3';
  static const String soundGentleWake = 'assets/sounds/gentle_wake.mp3';

  // Default Alarm Sounds
  static const List<Map<String, dynamic>> alarmSounds = [
    {
      'id': 'default',
      'name': 'Classic Alarm',
      'asset': 'assets/sounds/default_alarm.mp3',
      'icon': '🔔',
    },
    {
      'id': 'gentle',
      'name': 'Gentle Wake',
      'asset': 'assets/sounds/gentle_wake.mp3',
      'icon': '🌅',
    },
    {
      'id': 'energetic',
      'name': 'Energetic',
      'asset': 'assets/sounds/energetic.mp3',
      'icon': '⚡',
    },
    {
      'id': 'nature',
      'name': 'Nature Sounds',
      'asset': 'assets/sounds/nature.mp3',
      'icon': '🌲',
    },
  ];
}
