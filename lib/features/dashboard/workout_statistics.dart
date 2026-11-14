import '../../core/models/workout.dart';

/// A saved workout session count for one calendar day.
class DailyWorkoutCount {
  const DailyWorkoutCount({required this.date, required this.count});

  final DateTime date;
  final int count;
}

/// Workout totals calculated from the saved workout history.
class WorkoutStatistics {
  const WorkoutStatistics({
    required this.allTimeWorkoutCount,
    required this.weeklyWorkoutCount,
    required this.weeklyExerciseCount,
    required this.weeklySetCount,
    required this.weeklyRepCount,
    required this.weeklyActivity,
  });

  final int allTimeWorkoutCount;
  final int weeklyWorkoutCount;
  final int weeklyExerciseCount;
  final int weeklySetCount;
  final int weeklyRepCount;
  final List<DailyWorkoutCount> weeklyActivity;
}

/// Calculates session and training totals without changing saved workouts.
class WorkoutStatisticsCalculator {
  const WorkoutStatisticsCalculator._();

  /// Calculates all-time sessions and weekly activity for the week containing
  /// [referenceDate]. Weeks run Monday through Sunday using calendar dates.
  static WorkoutStatistics calculate({
    required List<Workout> workouts,
    required DateTime referenceDate,
  }) {
    // Use UTC calendar ordinals for differences so daylight-saving changes do
    // not turn a local calendar day into a 23- or 25-hour interval.
    final dayOrdinal = DateTime.utc(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final mondayOrdinal = dayOrdinal.subtract(
      Duration(days: dayOrdinal.weekday - 1),
    );
    final monday = DateTime(
      mondayOrdinal.year,
      mondayOrdinal.month,
      mondayOrdinal.day,
    );
    final dailyCounts = List<int>.filled(7, 0);
    final weekWorkouts = <Workout>[];

    for (final workout in workouts) {
      final workoutDay = DateTime.utc(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );
      final offset = workoutDay.difference(mondayOrdinal).inDays;
      if (offset >= 0 && offset < 7) {
        dailyCounts[offset]++;
        weekWorkouts.add(workout);
      }
    }

    final exerciseCount = weekWorkouts.fold<int>(
      0,
      (total, workout) => total + workout.exercises.length,
    );
    final setCount = weekWorkouts.fold<int>(
      0,
      (total, workout) =>
          total +
          workout.exercises.fold(
            0,
            (sum, exercise) => sum + exercise.sets.length,
          ),
    );
    final repCount = weekWorkouts.fold<int>(
      0,
      (total, workout) =>
          total +
          workout.exercises.fold(
            0,
            (exerciseTotal, exercise) =>
                exerciseTotal +
                exercise.sets.fold(0, (sum, set) => sum + set.reps),
          ),
    );

    return WorkoutStatistics(
      allTimeWorkoutCount: workouts.length,
      weeklyWorkoutCount: weekWorkouts.length,
      weeklyExerciseCount: exerciseCount,
      weeklySetCount: setCount,
      weeklyRepCount: repCount,
      weeklyActivity: List<DailyWorkoutCount>.generate(
        7,
        (index) => DailyWorkoutCount(
          date: monday.add(Duration(days: index)),
          count: dailyCounts[index],
        ),
        growable: false,
      ),
    );
  }
}
