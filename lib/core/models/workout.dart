import 'package:isar_community/isar.dart';

import 'exercise.dart';
import 'workout_set.dart';

/// A workout session containing the exercises completed on a date.
///
/// Isar stores each workout as a collection record. The nested exercises are
/// embedded in that record, so the complete workout is loaded and saved
/// together.
part 'workout.g.dart';

@collection
class Workout {
  /// Creates a workout. Isar assigns a unique [id] when it is first saved.
  Workout({
    this.id = Isar.autoIncrement,
    required this.date,
    this.exercises = const [],
  });

  /// The unique identifier assigned by Isar.
  Id id;

  /// The date when the workout took place.
  DateTime date;

  /// The exercises included in this workout.
  List<Exercise> exercises;
}
