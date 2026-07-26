import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_alarm/models/alarm_model.dart';
import 'package:stupid_alarm/services/alarm_watcher_service.dart';

void main() {
  group('AlarmWatcherService.isDue', () {
    // Sunday, 26 July 2026, 07:00.
    final sundaySeven = DateTime(2026, 7, 26, 7, 0, 30);

    AlarmModel alarm({
      TimeOfDay time = const TimeOfDay(hour: 7, minute: 0),
      List<int> repeatDays = const [],
      bool isEnabled = true,
    }) {
      return AlarmModel(
        id: 'a',
        label: 'A',
        time: time,
        repeatDays: repeatDays,
        isEnabled: isEnabled,
      );
    }

    test('one-time alarm is due at its minute', () {
      expect(AlarmWatcherService.isDue(alarm(), sundaySeven), isTrue);
    });

    test('disabled alarm is never due', () {
      expect(
        AlarmWatcherService.isDue(alarm(isEnabled: false), sundaySeven),
        isFalse,
      );
    });

    test('wrong minute is not due', () {
      expect(
        AlarmWatcherService.isDue(
          alarm(time: const TimeOfDay(hour: 7, minute: 1)),
          sundaySeven,
        ),
        isFalse,
      );
    });

    test('repeating alarm is due only on selected weekdays', () {
      // 0 = Sunday in this app's convention.
      expect(
        AlarmWatcherService.isDue(alarm(repeatDays: [0]), sundaySeven),
        isTrue,
      );
      expect(
        AlarmWatcherService.isDue(alarm(repeatDays: [1, 5]), sundaySeven),
        isFalse,
      );
    });
  });
}
