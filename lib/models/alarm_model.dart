import 'package:flutter/material.dart';

/// Model class representing an alarm
class AlarmModel {
  final String id;
  final String label;
  final TimeOfDay time;
  final List<int> repeatDays; // 0 = Sunday, 6 = Saturday
  final bool isEnabled;
  final bool isSmartMode;
  final String sound;
  final bool vibrate;
  final int snoozeDuration;

  AlarmModel({
    required this.id,
    required this.label,
    required this.time,
    this.repeatDays = const [],
    this.isEnabled = true,
    this.isSmartMode = false,
    this.sound = 'default',
    this.vibrate = true,
    this.snoozeDuration = 5,
  });

  /// Creates a copy of this alarm with modified fields
  AlarmModel copyWith({
    String? id,
    String? label,
    TimeOfDay? time,
    List<int>? repeatDays,
    bool? isEnabled,
    bool? isSmartMode,
    String? sound,
    bool? vibrate,
    int? snoozeDuration,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      label: label ?? this.label,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      isSmartMode: isSmartMode ?? this.isSmartMode,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
    );
  }

  /// Converts alarm to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'hour': time.hour,
      'minute': time.minute,
      'repeatDays': repeatDays,
      'isEnabled': isEnabled,
      'isSmartMode': isSmartMode,
      'sound': sound,
      'vibrate': vibrate,
      'snoozeDuration': snoozeDuration,
    };
  }

  /// Creates an alarm from a map
  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] as String,
      label: map['label'] as String,
      time: TimeOfDay(
        hour: map['hour'] as int,
        minute: map['minute'] as int,
      ),
      repeatDays: List<int>.from(map['repeatDays'] ?? []),
      isEnabled: map['isEnabled'] as bool? ?? true,
      isSmartMode: map['isSmartMode'] as bool? ?? false,
      sound: map['sound'] as String? ?? 'default',
      vibrate: map['vibrate'] as bool? ?? true,
      snoozeDuration: map['snoozeDuration'] as int? ?? 5,
    );
  }

  /// Gets a formatted time string
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Gets a 12-hour formatted time string
  String get formattedTime12Hour {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Gets the next alarm date
  DateTime? getNextAlarmDate() {
    final now = DateTime.now();
    final alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If alarm time has already passed today, schedule for tomorrow
    if (alarmDateTime.isBefore(now)) {
      return alarmDateTime.add(const Duration(days: 1));
    }

    return alarmDateTime;
  }

  @override
  String toString() {
    return 'AlarmModel{id: $id, label: $label, time: $formattedTime, repeatDays: $repeatDays, isEnabled: $isEnabled}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
