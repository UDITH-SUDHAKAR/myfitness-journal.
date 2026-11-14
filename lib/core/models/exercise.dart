import 'workout_set.dart';

/// An exercise performed as part of a workout.
class Exercise {
  /// Creates an exercise with its name and completed sets.
  Exercise({
    required this.name,
    this.sets = const [],
  });

  /// The name of the exercise, such as "Squat".
  final String name;

  /// The sets recorded for this exercise.
  final List<WorkoutSet> sets;
}
