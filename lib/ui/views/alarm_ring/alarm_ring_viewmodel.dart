import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../constants/app_constants.dart';
import '../../../models/alarm_model.dart';
import '../../../services/alarm_service.dart';
import '../../../services/notification_service.dart';
import '../../../utils/sit_up_detector.dart';
import '../home/home_view.dart';

class AlarmRingViewModel extends BaseViewModel {
  /// [enableAudio], [accelerometerStream], and [nowMs] exist as seams for
  /// widget tests, where the real plugins aren't available; production code
  /// uses the defaults.
  AlarmRingViewModel({
    bool enableAudio = true,
    Stream<AccelerometerEvent>? accelerometerStream,
    int Function()? nowMs,
  })  : _enableAudio = enableAudio,
        _accelerometerStreamOverride = accelerometerStream,
        _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final bool _enableAudio;
  final Stream<AccelerometerEvent>? _accelerometerStreamOverride;
  final int Function() _nowMs;

  final NotificationService _notificationService = NotificationService();
  final AlarmService _alarmService = locator<AlarmService>();
  final NavigationService _navigationService = NavigationService();

  AlarmModel? alarm;
  final SitUpDetector _detector = SitUpDetector();

  /// 0..1 — how long the upright pose has been held (Smart Mode only).
  double sitUpProgress = 0.0;

  bool get isMotionDetected => _detector.isComplete;
  bool get isDetectingMotion =>
      alarm?.isSmartMode == true && !_detector.isComplete;

  bool get canSnooze =>
      alarm != null &&
      !alarm!.isSmartMode &&
      alarm!.snoozeCount < AppConstants.defaultSnoozeLimit;

  int get snoozesLeft => alarm == null
      ? 0
      : (AppConstants.defaultSnoozeLimit - alarm!.snoozeCount)
          .clamp(0, AppConstants.defaultSnoozeLimit);

  AudioPlayer? _player;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _vibrationTimer;

  void initialize(AlarmModel alarmModel) {
    alarm = alarmModel;

    _startAlarmSound();
    _startVibration();
    if (alarm!.isSmartMode) {
      _startMotionDetection();
    }

    notifyListeners();
  }

  Future<void> _startAlarmSound() async {
    if (!_enableAudio) return;
    try {
      final player = AudioPlayer();
      _player = player;
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(_soundAssetPath), volume: 1.0);
    } catch (e) {
      // Keep ringing silently rather than crashing the ring screen —
      // the notification itself already played the system sound.
      debugPrint('Could not play alarm sound: $e');
    }
  }

  /// audioplayers resolves AssetSource relative to the assets/ folder.
  String get _soundAssetPath {
    final entry = AppConstants.alarmSounds.firstWhere(
      (sound) => sound['id'] == alarm?.sound,
      orElse: () => AppConstants.alarmSounds.first,
    );
    return (entry['asset'] as String).replaceFirst('assets/', '');
  }

  void _startVibration() {
    if (alarm?.vibrate != true) return;
    _vibrationTimer = Timer.periodic(
      const Duration(milliseconds: 800),
      (_) => HapticFeedback.heavyImpact(),
    );
  }

  void _startMotionDetection() {
    final stream = _accelerometerStreamOverride ?? accelerometerEventStream();
    _accelerometerSubscription = stream.listen(
      (AccelerometerEvent event) {
        final progress =
            _detector.addSample(event.x, event.y, event.z, _nowMs());

        if (_detector.isComplete) {
          _accelerometerSubscription?.cancel();
          _accelerometerSubscription = null;
          sitUpProgress = 1.0;
          HapticFeedback.mediumImpact(); // reward: the button just unlocked
          notifyListeners();
        } else if ((progress - sitUpProgress).abs() >= 0.01) {
          sitUpProgress = progress;
          notifyListeners();
        }
      },
      // A device (or emulator) without an accelerometer shouldn't trap the
      // user on the ring screen with a button that can never unlock.
      onError: (Object e) {
        debugPrint('Accelerometer unavailable, unlocking dismissal: $e');
        _detector.forceComplete();
        sitUpProgress = 1.0;
        notifyListeners();
      },
    );
  }

  Future<void> stopAlarm() async {
    await _cleanup();
    await _disableIfOneTime();

    _navigationService.clearStackAndShowView(const HomeView());
  }

  Future<void> snoozeAlarm() async {
    final current = alarm;
    if (current == null || !canSnooze) return;

    await _cleanup();
    // A one-time alarm has served its purpose once it rings; the pending
    // snooze notification carries the wake-up forward, not the base alarm.
    await _disableIfOneTime();

    final snoozeTime =
        DateTime.now().add(Duration(minutes: current.snoozeDuration));
    final snoozeAlarm = current.copyWith(
      // Stable id: re-snoozing replaces the previous snooze notification.
      id: current.id.endsWith('_snooze') ? current.id : '${current.id}_snooze',
      label: current.label.endsWith(' (Snoozed)')
          ? current.label
          : '${current.label} (Snoozed)',
      repeatDays: const [],
      isEnabled: true,
      snoozeCount: current.snoozeCount + 1,
    );

    await _notificationService.scheduleAlarmAt(snoozeAlarm, snoozeTime);

    _navigationService.clearStackAndShowView(const HomeView());
  }

  /// A one-time alarm that has rung should show as "off" on the home screen,
  /// exactly like stock alarm clocks. Snooze/test rings aren't in storage,
  /// so the lookup keeps them from being re-added.
  Future<void> _disableIfOneTime() async {
    final current = alarm;
    if (current == null || current.repeatDays.isNotEmpty) return;

    final baseId = current.id.endsWith('_snooze')
        ? current.id.substring(0, current.id.length - '_snooze'.length)
        : current.id;
    final stored = await _alarmService.getAlarmById(baseId);
    if (stored != null && stored.isEnabled && stored.repeatDays.isEmpty) {
      await _alarmService.saveAlarm(stored.copyWith(isEnabled: false));
    }
  }

  Future<void> _cleanup() async {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;

    final player = _player;
    _player = null;
    if (player != null) {
      try {
        await player.stop();
      } catch (_) {
        // Player may already be released; nothing to do.
      }
      player.dispose();
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
