import '../../core/models/workout.dart';
import 'exercise_identity.dart';

/// Statistics for one calendar week or month.
class WorkoutPeriodSummary {
  const WorkoutPeriodSummary({
    required this.startDate,
    required this.workoutCount,
    required this.exerciseCount,
    required this.setCount,
    required this.repCount,
    required this.volumeKg,
  });

  /// Monday for weekly summaries or the first day for monthly summaries.
  final DateTime startDate;
  final int workoutCount;
  final int exerciseCount;
  final int setCount;
  final int repCount;

  /// External-load volume: the sum of weight in kg multiplied by repetitions.
  final double volumeKg;
}

/// All-time statistics for one identifiable exercise.
class ExerciseWorkoutStatistics {
  const ExerciseWorkoutStatistics({
    required this.name,
    required this.libraryExerciseId,
    required this.sessionCount,
    required this.setCount,
    required this.repCount,
    required this.volumeKg,
  });

  final String name;
  final int? libraryExerciseId;
  final int sessionCount;
  final int setCount;
  final int repCount;
  final double volumeKg;
}

/// Calculates weekly, monthly, and per-exercise statistics from saved logs.
class WorkoutProgressCalculator {
  const WorkoutProgressCalculator._();

  static const int progressPeriodCount = 12;

  /// Returns the most recent 12 weeks, oldest first. Weeks start on Monday.
  static List<WorkoutPeriodSummary> weeklyProgress({
    required List<Workout> workouts,
    required DateTime referenceDate,
  }) {
    final referenceOrdinal = _calendarOrdinal(referenceDate);
    final currentMonday = referenceOrdinal.subtract(
      Duration(days: referenceOrdinal.weekday - 1),
    );
    final firstMonday = currentMonday.subtract(
      const Duration(days: 7 * (progressPeriodCount - 1)),
    );
    final weeks = List<List<Workout>>.generate(
      progressPeriodCount,
      (_) => <Workout>[],
    );

    for (final workout in workouts) {
      final offset = _calendarOrdinal(
        workout.date,
      ).difference(firstMonday).inDays;
      if (offset >= 0 && offset < 7 * progressPeriodCount) {
        weeks[offset ~/ 7].add(workout);
      }
    }

    return List<WorkoutPeriodSummary>.generate(
      progressPeriodCount,
      (index) => _summarize(
        startDate: _localDate(firstMonday.add(Duration(days: 7 * index))),
        workouts: weeks[index],
      ),
      growable: false,
    );
  }

  /// Returns the most recent 12 calendar months, oldest first.
  static List<WorkoutPeriodSummary> monthlyProgress({
    required List<Workout> workouts,
    required DateTime referenceDate,
  }) {
    final firstMonth = DateTime(
      referenceDate.year,
      referenceDate.month - progressPeriodCount + 1,
    );
    final months = List<List<Workout>>.generate(
      progressPeriodCount,
      (_) => <Workout>[],
    );
    final firstMonthIndex = _monthIndex(firstMonth);

    for (final workout in workouts) {
      final offset = _monthIndex(workout.date) - firstMonthIndex;
      if (offset >= 0 && offset < progressPeriodCount) {
        months[offset].add(workout);
      }
    }

    return List<WorkoutPeriodSummary>.generate(
      progressPeriodCount,
      (index) => _summarize(
        startDate: DateTime(firstMonth.year, firstMonth.month + index),
        workouts: months[index],
      ),
      growable: false,
    );
  }

  /// Returns all-time totals for each library or custom exercise identity.
  static List<ExerciseWorkoutStatistics> exerciseStatistics(
    List<Workout> workouts,
  ) {
    return ExerciseIdentity.groupWorkouts(workouts).map((group) {
      final sessions = Set<Workout>.identity();
      var setCount = 0;
      var repCount = 0;
      var volume = 0.0;
      for (final log in group.logs) {
        sessions.add(log.workout);
        setCount += log.exercise.sets.length;
        for (final set in log.exercise.sets) {
          if (set.reps > 0) repCount += set.reps;
          if (!_isValidVolumeSet(set.weight, set.reps)) continue;
          final setVolume = set.weight * set.reps;
          if (!setVolume.isFinite || !(volume + setVolume).isFinite) continue;
          volume += setVolume;
        }
      }
      return ExerciseWorkoutStatistics(
        name: group.name,
        libraryExerciseId: group.libraryExerciseId,
        sessionCount: sessions.length,
        setCount: setCount,
        repCount: repCount,
        volumeKg: volume,
      );
    }).toList();
  }

  static WorkoutPeriodSummary _summarize({
    required DateTime startDate,
    required List<Workout> workouts,
  }) {
    var exerciseCount = 0;
    var setCount = 0;
    var repCount = 0;
    var volume = 0.0;
    for (final workout in workouts) {
      exerciseCount += workout.exercises.length;
      for (final exercise in workout.exercises) {
        setCount += exercise.sets.length;
        for (final set in exercise.sets) {
          if (set.reps > 0) repCount += set.reps;
          if (!_isValidVolumeSet(set.weight, set.reps)) continue;
          final setVolume = set.weight * set.reps;
          if (!setVolume.isFinite || !(volume + setVolume).isFinite) continue;
          volume += setVolume;
        }
      }
    }
    return WorkoutPeriodSummary(
      startDate: startDate,
      workoutCount: workouts.length,
      exerciseCount: exerciseCount,
      setCount: setCount,
      repCount: repCount,
      volumeKg: volume,
    );
  }

  static bool _isValidVolumeSet(double weight, int reps) =>
      weight.isFinite && weight >= 0 && reps > 0;

  static DateTime _calendarOrdinal(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  static DateTime _localDate(DateTime utcDate) =>
      DateTime(utcDate.year, utcDate.month, utcDate.day);

  static int _monthIndex(DateTime date) => date.year * 12 + date.month - 1;
}
