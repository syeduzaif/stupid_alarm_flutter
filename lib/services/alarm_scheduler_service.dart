import '../models/alarm_model.dart';
import '../app/app.locator.dart';
import 'alarm_service.dart';
import 'notification_service.dart';

class AlarmSchedulerService {
  static AlarmSchedulerService? _instance;
  final AlarmService _alarmService = locator<AlarmService>();
  final NotificationService _notificationService = NotificationService();

  AlarmSchedulerService._internal();

  factory AlarmSchedulerService() {
    _instance ??= AlarmSchedulerService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _scheduleAllAlarms();
  }

  Future<void> _scheduleAllAlarms() async {
    final alarms = await _alarmService.getAllAlarms();
    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        await _notificationService.scheduleAlarm(alarm);
      }
    }
    print('Scheduled ${alarms.length} alarms');
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    await _notificationService.scheduleAlarm(alarm);
  }

  Future<void> cancelAlarm(String alarmId) async {
    await _notificationService.cancelAlarm(alarmId);
  }

  Future<void> rescheduleAllAlarms() async {
    await _notificationService.cancelAllAlarms();
    await _scheduleAllAlarms();
  }

  Future<void> onAlarmToggled(String alarmId, bool isEnabled) async {
    if (isEnabled) {
      final alarm = await _alarmService.getAlarmById(alarmId);
      if (alarm != null) {
        await scheduleAlarm(alarm);
      }
    } else {
      await cancelAlarm(alarmId);
    }
  }
}
