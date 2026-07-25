import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../models/alarm_model.dart';
import '../../../models/theme_mode_model.dart';
import '../../../services/alarm_service.dart';
import '../../../services/alarm_scheduler_service.dart';
import '../../../services/storage_service.dart';
import 'add_alarm_view.dart';

class HomeViewModel extends BaseViewModel {
  final AlarmService _alarmService = locator<AlarmService>();
  final AlarmSchedulerService _alarmScheduler = locator<AlarmSchedulerService>();
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = NavigationService();

  List<AlarmModel> _alarms = [];
  List<AlarmModel> get alarms => _alarms;

  AppThemeMode get themeMode => appThemeModeNotifier.value;

  Future<void> initialize() async {
    await loadAlarms();
  }

  Future<void> loadAlarms() async {
    setBusy(true);
    _alarms = await _alarmService.getAllAlarms();
    setBusy(false);
  }

  Future<void> toggleAlarm(String alarmId) async {
    final success = await _alarmService.toggleAlarm(alarmId);
    if (success) {
      // Get the updated alarm to check its enabled state
      final alarm = await _alarmService.getAlarmById(alarmId);
      if (alarm != null) {
        // Update scheduling based on new state
        await _alarmScheduler.onAlarmToggled(alarmId, alarm.isEnabled);
      }
      await loadAlarms();
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    final success = await _alarmService.deleteAlarm(alarmId);
    if (success) {
      // Cancel the scheduled alarm
      await _alarmScheduler.cancelAlarm(alarmId);
      await loadAlarms();
    }
  }

  void addAlarm() async {
    final result = await _navigationService.navigateToView(const AddAlarmView());
    if (result == true) {
      // Refresh alarms when returning from add alarm
      await loadAlarms();
    }
  }

  void editAlarm(String alarmId) async {
    final alarm = await _alarmService.getAlarmById(alarmId);
    if (alarm != null) {
      final result = await _navigationService.navigateToView(AddAlarmView(existingAlarm: alarm));
      if (result == true) {
        // Refresh alarms when returning from edit alarm
        await loadAlarms();
      }
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    appThemeModeNotifier.value = mode;
    await _storageService.setThemeMode(mode);
    notifyListeners();
  }

  /// Rings in a few seconds so the whole flow (notification → full-screen
  /// launch → ring screen → sit-up verification) can be tried on demand.
  Future<void> testAlarm() async {
    final now = DateTime.now();
    final ringAt = now.add(const Duration(seconds: 5));

    final testAlarm = AlarmModel(
      id: 'test_${now.millisecondsSinceEpoch}',
      label: 'Test Alarm',
      time: TimeOfDay(hour: ringAt.hour, minute: ringAt.minute),
      isEnabled: true,
      isSmartMode: true,
    );

    await _alarmScheduler.scheduleAlarmAt(testAlarm, ringAt);
  }
}
