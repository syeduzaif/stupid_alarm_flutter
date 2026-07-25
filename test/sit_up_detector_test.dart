import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_alarm/utils/sit_up_detector.dart';

/// Feeds [detector] a constant accelerometer reading at 50 Hz for
/// [duration], starting at [startMs]. Returns the last reported progress.
double feed(
  SitUpDetector detector,
  double x,
  double y,
  double z, {
  required int startMs,
  required Duration duration,
}) {
  var progress = 0.0;
  const stepMs = 20;
  for (var t = 0; t <= duration.inMilliseconds; t += stepMs) {
    progress = detector.addSample(x, y, z, startMs + t);
  }
  return progress;
}

void main() {
  group('SitUpDetector', () {
    const gravity = 9.81;

    test('phone lying flat never verifies (the original app bug)', () {
      final detector = SitUpDetector();
      final progress = feed(detector, 0, 0, gravity,
          startMs: 0, duration: const Duration(seconds: 10));

      expect(detector.isComplete, isFalse);
      expect(progress, 0.0);
    });

    test('holding the phone upright for the hold duration verifies', () {
      final detector = SitUpDetector();
      feed(detector, 0, gravity, 0,
          startMs: 0, duration: const Duration(seconds: 4));

      expect(detector.isComplete, isTrue);
    });

    test('progress rises while upright and resets when lying back down', () {
      final detector = SitUpDetector();

      // Held upright for half the required time → partial progress.
      final partial = feed(detector, 0, gravity, 0,
          startMs: 0, duration: const Duration(milliseconds: 1500));
      expect(partial, greaterThan(0.2));
      expect(detector.isComplete, isFalse);

      // Flops back flat → progress resets to zero.
      final reset = feed(detector, 0, 0, gravity,
          startMs: 1600, duration: const Duration(seconds: 1));
      expect(reset, 0.0);
      expect(detector.isComplete, isFalse);

      // Sits up again and holds properly this time → verifies.
      feed(detector, 0, gravity, 0,
          startMs: 2700, duration: const Duration(seconds: 4));
      expect(detector.isComplete, isTrue);
    });

    test('free-fall / bogus zero samples do not verify', () {
      final detector = SitUpDetector();
      final progress = feed(detector, 0, 0, 0,
          startMs: 0, duration: const Duration(seconds: 5));

      expect(detector.isComplete, isFalse);
      expect(progress, 0.0);
    });

    test('verification latches once complete', () {
      final detector = SitUpDetector();
      feed(detector, 0, gravity, 0,
          startMs: 0, duration: const Duration(seconds: 4));
      expect(detector.isComplete, isTrue);

      // Lying back down afterwards doesn't un-verify.
      final after = feed(detector, 0, 0, gravity,
          startMs: 5000, duration: const Duration(seconds: 1));
      expect(after, 1.0);
      expect(detector.isComplete, isTrue);
    });
  });
}
