import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_alarm/models/alarm_model.dart';

void main() {
  group('AlarmModel', () {
    final alarm = AlarmModel(
      id: '1753500000000',
      label: 'Work',
      time: const TimeOfDay(hour: 6, minute: 45),
      repeatDays: const [1, 2, 3, 4, 5],
      isEnabled: true,
      isSmartMode: true,
      sound: 'energetic',
      vibrate: false,
      snoozeDuration: 10,
      snoozeCount: 2,
    );

    test('toMap/fromMap round-trips every field', () {
      final restored = AlarmModel.fromMap(alarm.toMap());

      expect(restored.id, alarm.id);
      expect(restored.label, alarm.label);
      expect(restored.time, alarm.time);
      expect(restored.repeatDays, alarm.repeatDays);
      expect(restored.isEnabled, alarm.isEnabled);
      expect(restored.isSmartMode, alarm.isSmartMode);
      expect(restored.sound, alarm.sound);
      expect(restored.vibrate, alarm.vibrate);
      expect(restored.snoozeDuration, alarm.snoozeDuration);
      expect(restored.snoozeCount, alarm.snoozeCount);
    });

    test('fromMap tolerates maps stored by older app versions', () {
      // No snoozeCount / repeatDays keys — the pre-update storage format.
      final restored = AlarmModel.fromMap({
        'id': 'a',
        'label': 'Old',
        'hour': 7,
        'minute': 0,
      });

      expect(restored.snoozeCount, 0);
      expect(restored.repeatDays, isEmpty);
      expect(restored.isEnabled, isTrue);
      expect(restored.sound, 'default');
    });

    test('formattedTime12Hour handles midnight and noon', () {
      TimeOfDay t(int h, int m) => TimeOfDay(hour: h, minute: m);
      AlarmModel at(TimeOfDay time) => alarm.copyWith(time: time);

      expect(at(t(0, 5)).formattedTime12Hour, '12:05 AM');
      expect(at(t(12, 0)).formattedTime12Hour, '12:00 PM');
      expect(at(t(23, 59)).formattedTime12Hour, '11:59 PM');
      expect(at(t(6, 45)).formattedTime12Hour, '6:45 AM');
    });

    test('copyWith keeps unspecified fields', () {
      final copy = alarm.copyWith(label: 'Gym');
      expect(copy.label, 'Gym');
      expect(copy.id, alarm.id);
      expect(copy.snoozeCount, alarm.snoozeCount);
    });
  });
}
