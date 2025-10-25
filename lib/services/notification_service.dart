import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm_model.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to alarm ring screen
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to alarm ring screen
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;

    final now = DateTime.now();
    final alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    // If alarm time has already passed today, schedule for tomorrow
    DateTime scheduledTime = alarmDateTime;
    if (alarmDateTime.isBefore(now)) {
      scheduledTime = alarmDateTime.add(const Duration(days: 1));
    }

    // Handle repeat days
    if (alarm.repeatDays.isNotEmpty) {
      // For repeating alarms, schedule multiple notifications
      for (int day in alarm.repeatDays) {
        final daysUntilNext = _getDaysUntilNext(day, now.weekday);
        final repeatDateTime = scheduledTime.add(Duration(days: daysUntilNext));
        
        await _scheduleNotification(
          alarm.id + '_$day',
          alarm.label,
          'Time to wake up!',
          repeatDateTime,
          alarm,
        );
      }
    } else {
      // One-time alarm
      await _scheduleNotification(
        alarm.id,
        alarm.label,
        'Time to wake up!',
        scheduledTime,
        alarm,
      );
    }

    print('Scheduled alarm: ${alarm.label} at $scheduledTime');
  }

  Future<void> _scheduleNotification(
    String id,
    String title,
    String body,
    DateTime scheduledTime,
    AlarmModel alarm,
  ) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Notifications for alarm reminders',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      int.parse(id.replaceAll(RegExp(r'[^0-9]'), '')),
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarm.id,
    );
  }

  int _getDaysUntilNext(int targetDay, int currentDay) {
    // targetDay: 0=Sunday, 1=Monday, ..., 6=Saturday
    // currentDay: 1=Monday, 2=Tuesday, ..., 7=Sunday
    int currentDayOfWeek = currentDay == 7 ? 0 : currentDay;
    
    if (targetDay >= currentDayOfWeek) {
      return targetDay - currentDayOfWeek;
    } else {
      return 7 - currentDayOfWeek + targetDay;
    }
  }

  Future<void> cancelAlarm(String alarmId) async {
    await _notifications.cancel(int.parse(alarmId.replaceAll(RegExp(r'[^0-9]'), '')));
    print('Cancelled alarm: $alarmId');
  }

  Future<void> cancelAllAlarms() async {
    await _notifications.cancelAll();
    print('Cancelled all alarms');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
