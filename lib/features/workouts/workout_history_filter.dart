import 'package:flutter/material.dart';

import '../../core/models/workout.dart';

/// Applies the history's exercise-name and inclusive calendar-date filters.
class WorkoutHistoryFilter {
  /// Returns matching workouts without changing the supplied list.
  static List<Workout> apply({
    required List<Workout> workouts,
    required String exerciseName,
    DateTimeRange? dateRange,
  }) {
    final query = exerciseName.trim().toLowerCase();
    final start = dateRange == null ? null : _calendarDate(dateRange.start);
    final end = dateRange == null ? null : _calendarDate(dateRange.end);

    return workouts.where((workout) {
      final workoutDate = _calendarDate(workout.date);
      if (start != null && workoutDate.isBefore(start)) return false;
      if (end != null && workoutDate.isAfter(end)) return false;

      if (query.isEmpty) return true;
      return workout.exercises.any(
        (exercise) => exercise.name.toLowerCase().contains(query),
      );
    }).toList();
  }

  static DateTime _calendarDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
