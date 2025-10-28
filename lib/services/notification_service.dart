import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/alarm_model.dart';

class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    // Initialize timezone database so tz.TZDateTime works correctly
    tzdata.initializeTimeZones();

    // Get the device's timezone name and set it
    final String timeZoneName = DateTime.now().timeZoneName;

    // Common timezone mapping - extend this list as needed
    final timezoneMap = {
      'PKT': 'Asia/Karachi',
      'IST': 'Asia/Kolkata',
      'PST': 'America/Los_Angeles',
      'PDT': 'America/Los_Angeles',
      'EST': 'America/New_York',
      'EDT': 'America/New_York',
      'CST': 'America/Chicago',
      'CDT': 'America/Chicago',
      'MST': 'America/Denver',
      'MDT': 'America/Denver',
      'GMT': 'Europe/London',
      'BST': 'Europe/London',
      'CET': 'Europe/Paris',
      'JST': 'Asia/Tokyo',
      'AEST': 'Australia/Sydney',
    };

    try {
      // Try to map the timezone name to a location
      final locationName =
          timezoneMap[timeZoneName] ??
          'Asia/Karachi'; // Default to Pakistan time since that's your location

      final location = tz.getLocation(locationName);
      tz.setLocalLocation(location);

      // tz local set
    } catch (e) {
      // Fallback silently
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Request notification permissions
    await androidPlugin?.requestNotificationsPermission();

    // Request exact alarm permissions
    await androidPlugin?.requestExactAlarmsPermission();

    // Note: USE_FULL_SCREEN_INTENT permission must be requested in manifest
    // For Android 14+, also need to check in Settings
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to alarm ring screen
    // Handle tap
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

    // scheduled
  }

  Future<void> _scheduleNotification(
    String id,
    String title,
    String body,
    DateTime scheduledTime,
    AlarmModel alarm,
  ) async {
    final notificationId = _notificationIdFrom(id);

    // Log timezone info for debugging
    // timezone debug removed

    // Convert DateTime to TZDateTime using the local timezone
    final tzScheduledTime = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );

    // scheduling debug removed

    // Create notification details with alarm properties
    // Use device's default alarm sound URI
    const alarmSound = UriAndroidNotificationSound(
      'content://settings/system/alarm_alert',
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel_v3', // Changed channel to apply new sound settings
          'Alarms',
          channelDescription: 'Alarm notifications that ring until dismissed',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          playSound: true,
          sound: alarmSound, // Use device's default alarm sound
          enableVibration: true,
          vibrationPattern: Int64List.fromList([
            0,
            1000,
            500,
            1000,
            500,
            1000,
          ]), // Vibrate pattern
          ongoing: true, // Make it persistent
          autoCancel: false, // Don't auto-dismiss
          channelShowBadge: true,
          enableLights: true,
          ledColor: const Color(0xFFFF0000),
          ledOnMs: 1000,
          ledOffMs: 500,
          ticker: 'Alarm',
          when: scheduledTime.millisecondsSinceEpoch,
          usesChronometer: false,
          timeoutAfter: null, // Don't timeout
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'Tap to dismiss',
          ),
          // Additional settings for alarm behavior
          additionalFlags: Int32List.fromList([
            4, // FLAG_INSISTENT - loops sound until dismissed
            16, // FLAG_NO_CLEAR - can't be cleared by user swipe
            128, // FLAG_SHOW_WHEN - show the time
          ]),
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: alarm.id,
      );
      // scheduled
    } catch (e) {
      rethrow;
    }
  }

  int _notificationIdFrom(String id) {
    // Create a stable 32-bit positive integer from the string id
    final int hash = id.hashCode;
    // Ensure positive and within 32-bit signed range
    return (hash & 0x7fffffff) % 2147483647;
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
    await _notifications.cancel(_notificationIdFrom(alarmId));
    // cancelled
  }

  Future<void> cancelAllAlarms() async {
    await _notifications.cancelAll();
    // cancelled all
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Test method to show an immediate notification
  Future<void> showTestNotification() async {
    const alarmSound = UriAndroidNotificationSound(
      'content://settings/system/alarm_alert',
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel_v3',
          'Alarms',
          channelDescription: 'Alarm notifications that ring until dismissed',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          playSound: true,
          sound: alarmSound,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          ongoing: true,
          autoCancel: false,
          enableLights: true,
          ledColor: const Color(0xFFFF0000),
          additionalFlags: Int32List.fromList([
            4,
            16,
            128,
          ]), // INSISTENT + NO_CLEAR + SHOW_WHEN
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      999999,
      'Test Alarm',
      'This is a test notification to verify alarm system works',
      notificationDetails,
    );
    // test
  }

  /// Schedule a notification 10 seconds from now for testing
  Future<void> scheduleTestAlarmIn10Seconds() async {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    final tzScheduledTime = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );

    // test schedule

    const alarmSound = UriAndroidNotificationSound(
      'content://settings/system/alarm_alert',
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel_v3',
          'Alarms',
          channelDescription: 'Alarm notifications that ring until dismissed',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          playSound: true,
          sound: alarmSound,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          ongoing: true,
          autoCancel: false,
          enableLights: true,
          ledColor: const Color(0xFFFF0000),
          additionalFlags: Int32List.fromList([
            4,
            16,
            128,
          ]), // INSISTENT + NO_CLEAR + SHOW_WHEN
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      999998,
      'TEST Alarm - 10 seconds',
      'This alarm was scheduled 10 seconds ago!',
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    // test scheduled
  }
}
