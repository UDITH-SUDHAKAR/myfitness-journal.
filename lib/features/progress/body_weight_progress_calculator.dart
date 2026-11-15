import 'package:flutter/foundation.dart';

import '../../core/models/body_weight_entry.dart';

/// The time window shown by the body-weight progress chart.
enum BodyWeightProgressPeriod { weeks, months }

/// The actual measurements and summary values for one chart window.
@immutable
class BodyWeightProgress {
  const BodyWeightProgress({
    required this.startDate,
    required this.endDate,
    required this.entries,
  });

  /// First included calendar date.
  final DateTime startDate;

  /// Last included calendar date.
  final DateTime endDate;

  /// Measurements in chronological order. No missing dates are filled in.
  final List<BodyWeightEntry> entries;

  /// Earliest measurement in the window, if one exists.
  BodyWeightEntry? get firstEntry => entries.isEmpty ? null : entries.first;

  /// Latest measurement in the window, if one exists.
  BodyWeightEntry? get latestEntry => entries.isEmpty ? null : entries.last;

  /// Absolute weight difference between the first and latest measurements.
  ///
  /// Returns null when the window has fewer than two measurements.
  double? get absoluteChangeKg {
    final first = firstEntry;
    final latest = latestEntry;
    if (first == null || latest == null || entries.length < 2) return null;
    return (latest.weightKg - first.weightKg).abs();
  }

  /// Whether weight increased between the first and latest measurements.
  bool get increased {
    final first = firstEntry;
    final latest = latestEntry;
    return first != null && latest != null && latest.weightKg > first.weightKg;
  }
}

/// Selects body-weight measurements for the chart's calendar windows.
class BodyWeightProgressCalculator {
  const BodyWeightProgressCalculator._();

  /// Returns entries from the latest 12 Monday-to-Sunday weeks, through
  /// [referenceDate] inclusive. Weeks are counted by calendar date.
  static BodyWeightProgress forWeeks({
    required List<BodyWeightEntry> entries,
    required DateTime referenceDate,
  }) {
    final referenceDay = _dateOnly(referenceDate);
    final referenceOrdinal = _ordinal(referenceDay);
    final currentMonday = referenceOrdinal.subtract(
      Duration(days: referenceOrdinal.weekday - 1),
    );
    final firstMonday = currentMonday.subtract(const Duration(days: 77));
    return _forWindow(
      entries: entries,
      startDate: _localDate(firstMonday),
      endDate: referenceDay,
    );
  }

  /// Returns entries from the latest 12 calendar months, through
  /// [referenceDate] inclusive.
  static BodyWeightProgress forMonths({
    required List<BodyWeightEntry> entries,
    required DateTime referenceDate,
  }) {
    final referenceDay = _dateOnly(referenceDate);
    final firstMonth = DateTime(referenceDay.year, referenceDay.month - 11);
    return _forWindow(
      entries: entries,
      startDate: firstMonth,
      endDate: referenceDay,
    );
  }

  static BodyWeightProgress _forWindow({
    required List<BodyWeightEntry> entries,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final startOrdinal = _ordinal(startDate);
    final endOrdinalExclusive = _ordinal(endDate).add(const Duration(days: 1));
    final sortedEntries = entries.where((entry) {
      final entryDay = _ordinal(entry.date);
      return !entryDay.isBefore(startOrdinal) &&
          entryDay.isBefore(endOrdinalExclusive) &&
          entry.weightKg.isFinite &&
          entry.weightKg > 0;
    }).toList()..sort((first, second) => first.date.compareTo(second.date));

    return BodyWeightProgress(
      startDate: startDate,
      endDate: endDate,
      entries: List.unmodifiable(sortedEntries),
    );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// UTC ordinals make calendar-day differences stable across DST changes.
  static DateTime _ordinal(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  static DateTime _localDate(DateTime utcDate) =>
      DateTime(utcDate.year, utcDate.month, utcDate.day);
}
