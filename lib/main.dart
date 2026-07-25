import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app/app.locator.dart';
import 'app/app_theme.dart';
import 'models/theme_mode_model.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/alarm_scheduler_service.dart';
import 'ui/views/alarm_ring/alarm_ring_view.dart';
import 'ui/views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  setupLocator();

  // When an alarm notification is tapped (or full-screen launches over the
  // lock screen) while the app is alive, jump straight to the ring screen.
  NotificationService().onAlarmTriggered = (alarm) {
    StackedService.navigatorKey?.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AlarmRingView(alarm: alarm)),
      (route) => false,
    );
  };

  // Initialize alarm scheduler
  final alarmScheduler = locator<AlarmSchedulerService>();
  await alarmScheduler.initialize();

  // Seed the theme notifier before the first frame.
  appThemeModeNotifier.value = await locator<StorageService>().getThemeMode();

  runApp(const StupidAlarmApp());
}

class StupidAlarmApp extends StatelessWidget {
  const StupidAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Stupid Alarm',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(),
          darkTheme: AppTheme.getDarkTheme(),
          themeMode: switch (themeMode) {
            AppThemeMode.light => ThemeMode.light,
            AppThemeMode.dark => ThemeMode.dark,
            AppThemeMode.system => ThemeMode.system,
          },
          navigatorKey: StackedService.navigatorKey,
          home: const SplashView(),
        );
      },
    );
  }
}
