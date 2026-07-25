import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_alarm/utils/alarm_schedule.dart';

void main() {
  group('nextAlarmOccurrence', () {
    // Saturday, 25 July 2026, 10:30 local time.
    final now = DateTime(2026, 7, 25, 10, 30);

    test('later today when the time has not passed yet', () {
      final next =
          nextAlarmOccurrence(const TimeOfDay(hour: 22, minute: 0), now);
      expect(next, DateTime(2026, 7, 25, 22, 0));
    });

    test('tomorrow when the time has already passed', () {
      final next =
          nextAlarmOccurrence(const TimeOfDay(hour: 7, minute: 0), now);
      expect(next, DateTime(2026, 7, 26, 7, 0));
    });

    test('exactly now counts as passed', () {
      final next =
          nextAlarmOccurrence(const TimeOfDay(hour: 10, minute: 30), now);
      expect(next, DateTime(2026, 7, 26, 10, 30));
    });

    test('targets a specific weekday (0 = Sunday)', () {
      final sunday = nextAlarmOccurrence(
          const TimeOfDay(hour: 8, minute: 0), now,
          weekday: 0);
      expect(sunday, DateTime(2026, 7, 26, 8, 0));
      expect(sunday.weekday, DateTime.sunday);

      final wednesday = nextAlarmOccurrence(
          const TimeOfDay(hour: 8, minute: 0), now,
          weekday: 3);
      expect(wednesday, DateTime(2026, 7, 29, 8, 0));
      expect(wednesday.weekday, DateTime.wednesday);
    });

    test('same weekday rolls a full week when time has passed', () {
      // It's Saturday 10:30; a Saturday 7:00 alarm goes to next Saturday.
      final next = nextAlarmOccurrence(
          const TimeOfDay(hour: 7, minute: 0), now,
          weekday: 6);
      expect(next, DateTime(2026, 8, 1, 7, 0));
      expect(next.weekday, DateTime.saturday);
    });

    test('same weekday stays today when time is still ahead', () {
      final next = nextAlarmOccurrence(
          const TimeOfDay(hour: 23, minute: 0), now,
          weekday: 6);
      expect(next, DateTime(2026, 7, 25, 23, 0));
    });
  });
}
