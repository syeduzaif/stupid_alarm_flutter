import 'dart:math';

import '../constants/app_constants.dart';

/// Decides when the sleeper has genuinely sat up, from raw accelerometer
/// samples (gravity included).
///
/// The accelerometer is low-pass filtered to isolate gravity. Lying in bed
/// with the phone face-up puts gravity on the Z axis; sitting up and holding
/// the phone in front of you rotates gravity onto the +Y axis (top edge
/// pointing at the ceiling). The detector requires that upright orientation
/// to be held continuously for [holdDuration] — dropping back flat resets
/// the timer, so a brief wave of the phone doesn't count.
class SitUpDetector {
  SitUpDetector({
    this.uprightThreshold = AppConstants.tiltThreshold,
    this.holdDuration = const Duration(seconds: AppConstants.tiltCheckDuration),
  });

  /// Minimum fraction of gravity that must sit on the +Y axis (0.7 ≈ the
  /// phone tilted within ~45° of vertical).
  final double uprightThreshold;

  /// How long the upright pose must be held before the alarm unlocks.
  final Duration holdDuration;

  double _gx = 0, _gy = 0, _gz = 0;
  bool _hasSample = false;
  int? _uprightSinceMs;
  bool _completed = false;

  /// Whether the sit-up has been verified. Latches true once reached.
  bool get isComplete => _completed;

  /// Marks verification as passed without sensor input — the escape hatch
  /// for hardware without an accelerometer.
  void forceComplete() => _completed = true;

  /// Feeds one accelerometer sample (m/s², gravity included) taken at
  /// [nowMs]. Returns hold progress in [0, 1]; 1.0 means verified.
  double addSample(double x, double y, double z, int nowMs) {
    if (_completed) return 1.0;

    // Low-pass filter to estimate the gravity vector.
    const alpha = 0.8;
    if (_hasSample) {
      _gx = alpha * _gx + (1 - alpha) * x;
      _gy = alpha * _gy + (1 - alpha) * y;
      _gz = alpha * _gz + (1 - alpha) * z;
    } else {
      _gx = x;
      _gy = y;
      _gz = z;
      _hasSample = true;
    }

    final magnitude = sqrt(_gx * _gx + _gy * _gy + _gz * _gz);
    if (magnitude < 1e-3) return 0.0; // free fall / bogus sample

    final uprightness = _gy / magnitude;
    if (uprightness < uprightThreshold) {
      _uprightSinceMs = null;
      return 0.0;
    }

    _uprightSinceMs ??= nowMs;
    final heldMs = nowMs - _uprightSinceMs!;
    if (heldMs >= holdDuration.inMilliseconds) {
      _completed = true;
      return 1.0;
    }
    return heldMs / holdDuration.inMilliseconds;
  }
}
