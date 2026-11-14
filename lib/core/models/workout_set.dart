/// One set performed for an exercise during a workout.
class WorkoutSet {
  /// Creates a set with its weight, repetitions, and position in the exercise.
  const WorkoutSet({
    required this.weight,
    required this.reps,
    required this.setNumber,
  });

  /// The weight used for this set.
  final double weight;

  /// The number of repetitions completed.
  final int reps;

  /// The position of this set within the exercise, starting at 1.
  final int setNumber;
}
