import 'exercise.dart';

/// A workout session containing the exercises completed on a date.
class Workout {
  /// Creates a workout with the given date and exercises.
  Workout({
    required this.date,
    this.exercises = const [],
  });

  /// The date when the workout took place.
  final DateTime date;

  /// The exercises included in this workout.
  final List<Exercise> exercises;
}

