import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../models/alarm_model.dart';
import '../../../services/alarm_service.dart';
import '../../../services/alarm_scheduler_service.dart';

class AddAlarmViewModel extends BaseViewModel {
  final AlarmService _alarmService = locator<AlarmService>();
  final AlarmSchedulerService _alarmScheduler = locator<AlarmSchedulerService>();
  final NavigationService _navigationService = NavigationService();

  // Form controllers and state
  late TextEditingController labelController;
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedSound = 'default';
  bool isSmartMode = false;
  List<int> repeatDays = [];
  int snoozeDuration = 5;
  String? alarmId; // For editing existing alarms

  void initialize(AlarmModel? existingAlarm) {
    if (existingAlarm != null) {
      // Editing existing alarm
      alarmId = existingAlarm.id;
      labelController = TextEditingController(text: existingAlarm.label);
      selectedTime = existingAlarm.time;
      selectedSound = existingAlarm.sound;
      isSmartMode = existingAlarm.isSmartMode;
      repeatDays = List.from(existingAlarm.repeatDays);
      snoozeDuration = existingAlarm.snoozeDuration;
    } else {
      // Creating new alarm
      labelController = TextEditingController();
      // Set default time to 7:00 AM
      selectedTime = const TimeOfDay(hour: 7, minute: 0);
    }
    notifyListeners();
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFFF4D4D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      selectedTime = picked;
      notifyListeners();
    }
  }

  void setSelectedSound(String sound) {
    selectedSound = sound;
    notifyListeners();
  }

  void setSmartMode(bool value) {
    isSmartMode = value;
    notifyListeners();
  }

  void toggleRepeatDay(int day) {
    if (repeatDays.contains(day)) {
      repeatDays.remove(day);
    } else {
      repeatDays.add(day);
    }
    repeatDays.sort();
    notifyListeners();
  }

  void setSnoozeDuration(int duration) {
    snoozeDuration = duration;
    notifyListeners();
  }

  Future<void> saveAlarm() async {
    if (isBusy) return;

    setBusy(true);

    try {
      // Generate alarm ID if creating new alarm
      final String id = alarmId ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      // Get label or use default
      final String timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      final String label = labelController.text.trim().isEmpty 
          ? 'Alarm $timeString' 
          : labelController.text.trim();

      // Create alarm model
      final AlarmModel alarm = AlarmModel(
        id: id,
        label: label,
        time: selectedTime,
        repeatDays: repeatDays,
        isEnabled: true,
        isSmartMode: isSmartMode,
        sound: selectedSound,
        vibrate: true,
        snoozeDuration: snoozeDuration,
      );

      // Save alarm
      print('Saving alarm: $alarm');
      final bool success = await _alarmService.saveAlarm(alarm);
      print('Save result: $success');
      
      if (success) {
        // Schedule the alarm notification
        await _alarmScheduler.scheduleAlarm(alarm);
        print('Alarm scheduled successfully');
        
        // Navigate back to home with result
        _navigationService.back(result: true);
      } else {
        // Show error message
        _showErrorDialog('Failed to save alarm. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    } finally {
      setBusy(false);
    }
  }

  void _showErrorDialog(String message) {
    // For now, just print the error
    // In a real app, you'd show a proper dialog
    print('Error: $message');
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }
}
