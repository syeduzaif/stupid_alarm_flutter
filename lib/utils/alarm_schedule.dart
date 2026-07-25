import 'package:flutter/material.dart';

/// Returns the next moment [time] occurs strictly after [now].
///
/// With [weekday] set (this app's convention: 0 = Sunday … 6 = Saturday), the
/// result additionally falls on that weekday — up to a full week ahead when
/// today's occurrence has already passed. Dates are built via the DateTime
/// constructor (not Duration math) so wall-clock time survives DST changes.
DateTime nextAlarmOccurrence(TimeOfDay time, DateTime now, {int? weekday}) {
  for (var daysAhead = 0; daysAhead <= 7; daysAhead++) {
    final candidate = DateTime(
      now.year,
      now.month,
      now.day + daysAhead,
      time.hour,
      time.minute,
    );
    if (!candidate.isAfter(now)) continue;
    if (weekday == null || candidate.weekday % 7 == weekday) {
      return candidate;
    }
  }
  throw StateError('No occurrence found within a week — unreachable');
}
