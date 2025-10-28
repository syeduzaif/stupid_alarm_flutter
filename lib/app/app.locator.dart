import 'package:get_it/get_it.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
import '../services/alarm_scheduler_service.dart';

// This file contains the code for dependency injection setup
// Run this command to generate the file:
// flutter pub run build_runner build --delete-conflicting-outputs

/// Initializes services and registers them with the dependency injection system
final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register services as singletons
  locator.registerLazySingleton<AlarmService>(() => AlarmService());
  locator.registerLazySingleton<StorageService>(() => StorageService());
  locator.registerLazySingleton<AlarmSchedulerService>(() => AlarmSchedulerService());
}
