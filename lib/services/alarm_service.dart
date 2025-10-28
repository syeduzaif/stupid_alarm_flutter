import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/alarm_model.dart';
import '../constants/app_constants.dart';

/// Service to manage alarm storage and retrieval
class AlarmService {
  static AlarmService? _instance;

  AlarmService._internal();

  factory AlarmService() {
    _instance ??= AlarmService._internal();
    return _instance!;
  }

  /// Get all stored alarms
  Future<List<AlarmModel>> getAllAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? alarmsJson = prefs.getString(AppConstants.keyAlarms);

      if (alarmsJson == null) {
        return [];
      }

      final List<dynamic> alarmsData = json.decode(alarmsJson);
      final alarms = alarmsData
          .map((data) => AlarmModel.fromMap(data))
          .toList();

      return alarms;
    } catch (e) {
      return [];
    }
  }

  /// Save an alarm
  Future<bool> saveAlarm(AlarmModel alarm) async {
    try {
      final alarms = await getAllAlarms();

      // Check if alarm already exists
      final index = alarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        alarms[index] = alarm;
      } else {
        alarms.add(alarm);
      }

      final prefs = await SharedPreferences.getInstance();
      final String alarmsJson = json.encode(
        alarms.map((a) => a.toMap()).toList(),
      );

      final result = await prefs.setString(AppConstants.keyAlarms, alarmsJson);

      return result;
    } catch (e) {
      return false;
    }
  }

  /// Delete an alarm
  Future<bool> deleteAlarm(String alarmId) async {
    try {
      final alarms = await getAllAlarms();
      alarms.removeWhere((a) => a.id == alarmId);

      final prefs = await SharedPreferences.getInstance();
      final String alarmsJson = json.encode(
        alarms.map((a) => a.toMap()).toList(),
      );

      return await prefs.setString(AppConstants.keyAlarms, alarmsJson);
    } catch (e) {
      return false;
    }
  }

  /// Toggle alarm enabled state
  Future<bool> toggleAlarm(String alarmId) async {
    try {
      final alarms = await getAllAlarms();
      final index = alarms.indexWhere((a) => a.id == alarmId);

      if (index != -1) {
        final alarm = alarms[index];
        alarms[index] = alarm.copyWith(isEnabled: !alarm.isEnabled);

        final prefs = await SharedPreferences.getInstance();
        final String alarmsJson = json.encode(
          alarms.map((a) => a.toMap()).toList(),
        );

        return await prefs.setString(AppConstants.keyAlarms, alarmsJson);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get alarm by ID
  Future<AlarmModel?> getAlarmById(String alarmId) async {
    try {
      final alarms = await getAllAlarms();
      final index = alarms.indexWhere((a) => a.id == alarmId);

      if (index != -1) {
        return alarms[index];
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
