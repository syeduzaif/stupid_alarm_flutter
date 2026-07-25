import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm_model.dart';
import '../utils/alarm_schedule.dart';
import '../utils/notification_id.dart';

class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Set by the app shell (main.dart). Invoked with the decoded alarm when
  /// the user taps an alarm notification while the app process is alive.
  void Function(AlarmModel alarm)? onAlarmTriggered;

  NotificationService._internal();

  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    final alarm = alarmFromPayload(response.payload);
    if (alarm != null) {
      onAlarmTriggered?.call(alarm);
    }
  }

  /// Decodes the alarm JSON stashed in every notification payload. Returns
  /// null for missing or malformed payloads.
  static AlarmModel? alarmFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      return AlarmModel.fromMap(json.decode(payload) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Could not decode alarm payload: $e');
      return null;
    }
  }

  /// If the app process was cold-started from an alarm notification (tap or
  /// full-screen intent), returns that alarm so the app can go straight to
  /// the ring screen.
  Future<AlarmModel?> getLaunchAlarm() async {
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return alarmFromPayload(details!.notificationResponse?.payload);
    }
    return null;
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;

    final now = DateTime.now();
    if (alarm.repeatDays.isEmpty) {
      // One-time alarm: next occurrence of hh:mm.
      await _zonedSchedule(
        notificationIdFor(alarm.id),
        nextAlarmOccurrence(alarm.time, now),
        alarm,
      );
    } else {
      // Repeating alarm: one weekly-repeating notification per weekday.
      for (final day in alarm.repeatDays) {
        await _zonedSchedule(
          notificationIdFor('${alarm.id}_$day'),
          nextAlarmOccurrence(alarm.time, now, weekday: day),
          alarm,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  /// Schedules a one-shot ring at an exact moment. Used for snoozes and test
  /// alarms, which need second precision rather than the next hh:mm.
  Future<void> scheduleAlarmAt(AlarmModel alarm, DateTime when) async {
    await _zonedSchedule(notificationIdFor(alarm.id), when, alarm);
  }

  Future<void> _zonedSchedule(
    int id,
    DateTime when,
    AlarmModel alarm, {
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    await _notifications.zonedSchedule(
      id,
      alarm.label,
      'Time to wake up!',
      tz.TZDateTime.from(when, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchDateTimeComponents,
      payload: json.encode(alarm.toMap()),
    );

    debugPrint('Scheduled "${alarm.label}" (#$id) for $when');
  }

  /// Cancels the alarm's one-time notification and all its per-weekday
  /// repeats (ids are deterministic, so no bookkeeping is needed).
  Future<void> cancelAlarm(String alarmId) async {
    await _notifications.cancel(notificationIdFor(alarmId));
    for (var day = 0; day < 7; day++) {
      await _notifications.cancel(notificationIdFor('${alarmId}_$day'));
    }
  }

  Future<void> cancelAllAlarms() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
