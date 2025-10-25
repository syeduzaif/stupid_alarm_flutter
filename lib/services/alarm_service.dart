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
      print('Retrieved alarms JSON: $alarmsJson');

      if (alarmsJson == null) {
        print('No alarms found in storage');
        return [];
      }

      final List<dynamic> alarmsData = json.decode(alarmsJson);
      final alarms = alarmsData.map((data) => AlarmModel.fromMap(data)).toList();
      print('Parsed ${alarms.length} alarms from storage');
      return alarms;
    } catch (e) {
      print('Error loading alarms: $e');
      return [];
    }
  }

  /// Save an alarm
  Future<bool> saveAlarm(AlarmModel alarm) async {
    try {
      final alarms = await getAllAlarms();
      print('Current alarms before save: ${alarms.length}');
      
      // Check if alarm already exists
      final index = alarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        alarms[index] = alarm;
        print('Updated existing alarm at index $index');
      } else {
        alarms.add(alarm);
        print('Added new alarm. Total alarms: ${alarms.length}');
      }

      final prefs = await SharedPreferences.getInstance();
      final String alarmsJson = json.encode(
        alarms.map((a) => a.toMap()).toList(),
      );
      print('Saving alarms JSON: $alarmsJson');

      final result = await prefs.setString(AppConstants.keyAlarms, alarmsJson);
      print('Save result: $result');
      return result;
    } catch (e) {
      print('Error saving alarm: $e');
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
