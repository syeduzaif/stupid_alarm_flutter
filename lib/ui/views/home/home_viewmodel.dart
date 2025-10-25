import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../models/alarm_model.dart';
import '../../../services/alarm_service.dart';
import '../../../services/alarm_scheduler_service.dart';
import 'add_alarm_view.dart';

class HomeViewModel extends BaseViewModel {
  final AlarmService _alarmService = locator<AlarmService>();
  final AlarmSchedulerService _alarmScheduler = locator<AlarmSchedulerService>();
  final NavigationService _navigationService = NavigationService();

  List<AlarmModel> _alarms = [];
  List<AlarmModel> get alarms => _alarms;

  Future<void> initialize() async {
    await loadAlarms();
  }

  void onModelReady() {
    // This is called when the view becomes active
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    setBusy(true);
    _alarms = await _alarmService.getAllAlarms();
    print('Loaded ${_alarms.length} alarms: $_alarms');
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

  void navigateToSettings() {
    // TODO: Implement settings navigation
    // For now, show a placeholder dialog
    print('Settings navigation not yet implemented');
  }

  void testAlarm() async {
    // Create a test alarm that rings in 5 seconds
    final now = DateTime.now();
    final testDateTime = now.add(const Duration(seconds: 5));
    final testTime = TimeOfDay(hour: testDateTime.hour, minute: testDateTime.minute);
    
    final testAlarm = AlarmModel(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      label: 'Test Alarm',
      time: testTime,
      isEnabled: true,
      isSmartMode: false,
    );
    
    print('Creating test alarm for ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}');
    await _alarmScheduler.scheduleAlarm(testAlarm);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
