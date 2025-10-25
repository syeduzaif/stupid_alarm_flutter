import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app/app.locator.dart';
import 'app/app_theme.dart';
import 'models/theme_mode_model.dart';
import 'services/storage_service.dart';
import 'services/alarm_scheduler_service.dart';
import 'ui/views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  setupLocator();
  
  // Initialize alarm scheduler
  final alarmScheduler = locator<AlarmSchedulerService>();
  await alarmScheduler.initialize();
  
  runApp(const StupidAlarmApp());
}

class StupidAlarmApp extends StatefulWidget {
  const StupidAlarmApp({super.key});

  @override
  State<StupidAlarmApp> createState() => _StupidAlarmAppState();
}

class _StupidAlarmAppState extends State<StupidAlarmApp> {
  AppThemeMode _themeMode = AppThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final storageService = locator<StorageService>();
    final themeMode = await storageService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stupid Alarm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: _themeMode == AppThemeMode.light
          ? ThemeMode.light
          : _themeMode == AppThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.system,
      navigatorKey: StackedService.navigatorKey,
      home: const SplashView(),
    );
  }
}
