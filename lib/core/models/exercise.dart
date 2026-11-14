import 'package:isar_community/isar.dart';

import 'workout_set.dart';

/// An exercise performed as part of a workout.
///
/// This is embedded in a workout, so it has no separate database ID.
part 'exercise.g.dart';

@embedded
class Exercise {
  /// Creates an exercise with its name and completed sets.
  ///
  /// Isar needs an embedded object to have a constructor without required
  /// arguments. The defaults also make an empty exercise safe to create.
  Exercise({this.name = '', this.sets = const [], this.libraryExerciseId});

  /// The name of the exercise, such as "Squat".
  String name;

  /// ID of the library entry this exercise was copied from, if any.
  ///
  /// The name above remains a snapshot so workout history still reads well
  /// when a library item is later renamed or deleted.
  @Name('workoutLibraryExerciseId')
  int? libraryExerciseId;

  /// The sets recorded for this exercise.
  List<WorkoutSet> sets;
}
