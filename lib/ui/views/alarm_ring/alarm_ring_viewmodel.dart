import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../../../models/alarm_model.dart';
import '../../../services/notification_service.dart';
import '../../../constants/app_constants.dart';
import '../home/home_view.dart';

class AlarmRingViewModel extends BaseViewModel {
  final NotificationService _notificationService = NotificationService();
  final NavigationService _navigationService = NavigationService();

  AlarmModel? alarm;
  bool isMotionDetected = false;
  bool isDetectingMotion = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _motionDetectionTimer;

  void initialize(AlarmModel alarmModel) {
    alarm = alarmModel;

    if (alarm!.isSmartMode) {
      _startMotionDetection();
    }

    notifyListeners();
  }

  void _startMotionDetection() {
    isDetectingMotion = true;
    notifyListeners();

    // Listen to accelerometer data
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      // Calculate the magnitude of acceleration
      final double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Check if the phone is being moved significantly (indicating sitting up)
      if (magnitude > AppConstants.tiltThreshold) {
        _onMotionDetected();
      }
    });

    // Start a timer to periodically check motion
    _motionDetectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Motion detection logic is handled in the accelerometer listener
    });
  }

  void _onMotionDetected() {
    if (!isMotionDetected) {
      isMotionDetected = true;
      isDetectingMotion = false;
      notifyListeners();

      // Provide haptic feedback
      _provideHapticFeedback();
    }
  }

  void _provideHapticFeedback() {
    // Use Flutter's built-in haptic feedback
    // This will work without additional packages
    try {
      // Note: This is a placeholder - actual haptic feedback would need
      // platform-specific implementation or a working vibration package
    } catch (e) {
      // Handle error silently
    }
  }

  void stopAlarm() {
    _cleanup();

    // Navigate back to home
    _navigationService.clearStackAndShowView(const HomeView());
  }

  void snoozeAlarm() async {
    if (alarm == null) return;

    _cleanup();

    // Create a snooze alarm that rings after the snooze duration
    final now = DateTime.now();
    final snoozeTime = now.add(Duration(minutes: alarm!.snoozeDuration));
    final snoozeTimeOfDay = TimeOfDay(
      hour: snoozeTime.hour,
      minute: snoozeTime.minute,
    );

    final snoozeAlarm = AlarmModel(
      id: '${alarm!.id}_snooze_${now.millisecondsSinceEpoch}',
      label: '${alarm!.label} (Snooze)',
      time: snoozeTimeOfDay,
      isEnabled: true,
      isSmartMode: false,
      repeatDays: [],
      sound: alarm!.sound,
      vibrate: alarm!.vibrate,
      snoozeDuration: alarm!.snoozeDuration,
    );

    // Schedule the snooze alarm
    await _notificationService.scheduleAlarm(snoozeAlarm);

    // Navigate back to home
    _navigationService.clearStackAndShowView(const HomeView());
  }

  void _cleanup() {
    _accelerometerSubscription?.cancel();
    _motionDetectionTimer?.cancel();
    _accelerometerSubscription = null;
    _motionDetectionTimer = null;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
