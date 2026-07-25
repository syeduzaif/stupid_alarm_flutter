import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_alarm/utils/notification_id.dart';

void main() {
  group('notificationIdFor', () {
    test('always fits in a positive signed 32-bit int', () {
      final keys = [
        '1753500000000', // millisecond-timestamp id
        '1753500000000_snooze',
        '1753500000000_snooze_1753500300000', // legacy double-timestamp shape
        'test_1753500000000',
        for (var day = 0; day < 7; day++) '1753500000000_$day',
      ];

      for (final key in keys) {
        final id = notificationIdFor(key);
        expect(id, greaterThanOrEqualTo(0), reason: key);
        expect(id, lessThanOrEqualTo(0x7FFFFFFF), reason: key);
      }
    });

    test('is deterministic across calls', () {
      expect(
        notificationIdFor('1753500000000'),
        notificationIdFor('1753500000000'),
      );
    });

    test('distinguishes an alarm from its weekday and snooze variants', () {
      const base = '1753500000000';
      final ids = <int>{
        notificationIdFor(base),
        notificationIdFor('${base}_snooze'),
        for (var day = 0; day < 7; day++) notificationIdFor('${base}_$day'),
      };
      expect(ids, hasLength(9)); // no collisions among related keys
    });
  });
}
