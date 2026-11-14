import 'package:isar_community/isar.dart';

/// One set performed for an exercise during a workout.
///
/// This is embedded in an exercise, so it has no separate database ID.
part 'workout_set.g.dart';

@embedded
class WorkoutSet {
  /// Creates a set with its weight, repetitions, and position in the exercise.
  /// Isar can create an empty embedded object using these defaults.
  WorkoutSet({this.weight = 0, this.reps = 0, this.setNumber = 1});

  /// The weight used for this set.
  double weight;

  /// The number of repetitions completed.
  int reps;

  /// The position of this set within the exercise, starting at 1.
  int setNumber;
}
