import 'dart:async';

import 'package:flutter/widgets.dart';

import '../app/app.locator.dart';
import '../models/alarm_model.dart';
import 'alarm_service.dart';
import 'notification_service.dart';

/// Opens the ring screen directly when an alarm comes due while the user is
/// inside the app.
///
/// The scheduled notification stays the source of truth for waking a dead or
/// locked device — but when the user is actively using the app, Android
/// deliberately downgrades the full-screen intent to a heads-up banner. This
/// watcher closes that gap: it ticks while the app process is alive and, if
/// an alarm strikes while the app is resumed, rings in-app immediately and
/// clears the now-redundant banner.
class AlarmWatcherService {
  static AlarmWatcherService? _instance;
  final AlarmService _alarmService = locator<AlarmService>();
  final NotificationService _notificationService = NotificationService();

  Timer? _ticker;
  final Map<String, int> _lastFiredMinute = {};
  final List<_OneShot> _oneShots = [];

  /// Set by AlarmRingViewModel while the ring screen is up, so the watcher
  /// never stacks a second ring on top of an active one.
  bool ringInProgress = false;

  AlarmWatcherService._internal();

  factory AlarmWatcherService() {
    _instance ??= AlarmWatcherService._internal();
    return _instance!;
  }

  void start() {
    _ticker ??= Timer.periodic(const Duration(seconds: 2), (_) => _tick());
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Watches a ring scheduled for an exact moment (snoozes, test alarms),
  /// which lives only in the notification payload — not in storage.
  void watchOneShot(AlarmModel alarm, DateTime at) {
    _oneShots.add(_OneShot(alarm, at));
  }

  Future<void> _tick() async {
    // Only ring in-app while the user is actually looking at the app; in
    // every other state (background, locked, dead) the notification owns
    // the alarm and cancelling its banner would hide it from the user.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    if (ringInProgress) return;

    final now = DateTime.now();

    // Exact one-shots first — they carry second precision.
    for (final shot in _oneShots) {
      if (!shot.at.isAfter(now)) {
        _oneShots.remove(shot);
        await _fire(shot.alarm, rescheduleRepeats: false);
        return;
      }
    }

    for (final alarm in await _alarmService.getAllAlarms()) {
      if (!isDue(alarm, now)) continue;
      final minuteStamp = now.millisecondsSinceEpoch ~/ 60000;
      if (_lastFiredMinute[alarm.id] == minuteStamp) continue;
      _lastFiredMinute[alarm.id] = minuteStamp;
      await _fire(alarm, rescheduleRepeats: true);
      return;
    }
  }

  /// Pure due-check: enabled, hh:mm matches, and today is a selected repeat
  /// day (or the alarm is one-time). Weekday convention: 0 = Sunday.
  static bool isDue(AlarmModel alarm, DateTime now) {
    if (!alarm.isEnabled) return false;
    if (alarm.time.hour != now.hour || alarm.time.minute != now.minute) {
      return false;
    }
    if (alarm.repeatDays.isEmpty) return true;
    return alarm.repeatDays.contains(now.weekday % 7);
  }

  Future<void> _fire(AlarmModel alarm, {required bool rescheduleRepeats}) async {
    // The in-app ring supersedes whatever banner this occurrence produced.
    // Cancelling also drops future weekly repeats, so put those back.
    await _notificationService.cancelAlarm(alarm.id);
    if (rescheduleRepeats && alarm.repeatDays.isNotEmpty) {
      await _notificationService.scheduleAlarm(alarm);
    }
    _notificationService.onAlarmTriggered?.call(alarm);
  }
}

class _OneShot {
  final AlarmModel alarm;
  final DateTime at;

  _OneShot(this.alarm, this.at);
}
