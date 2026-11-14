import '../../core/models/exercise.dart';
import '../../core/models/personal_record.dart';
import '../../core/models/workout.dart';
import '../../core/models/workout_set.dart';
import 'exercise_identity.dart';

/// Calculates personal bests from saved workouts without persisting them.
class PersonalRecordCalculator {
  /// Builds one record summary per library exercise or custom exercise name.
  static List<ExercisePersonalRecords> calculate(
    List<Workout> workouts, {
    int? excludeWorkoutId,
  }) {
    final records = <ExercisePersonalRecords>[];
    final workoutsToRead = workouts
        .where((workout) => workout.id != excludeWorkoutId)
        .toList();

    for (final exerciseGroup in ExerciseIdentity.groupWorkouts(
      workoutsToRead,
    )) {
      PersonalRecordMark? heaviestSet;
      PersonalRecordMark? mostReps;
      for (final log in exerciseGroup.logs) {
        for (final set in log.exercise.sets) {
          if (!_isValidSet(set)) continue;
          if (set.weight > 0 &&
              (heaviestSet == null || set.weight > heaviestSet.weight)) {
            heaviestSet = PersonalRecordMark(
              weight: set.weight,
              reps: set.reps,
              date: log.workout.date,
            );
          }
          if (mostReps == null || set.reps > mostReps.reps) {
            mostReps = PersonalRecordMark(
              weight: set.weight,
              reps: set.reps,
              date: log.workout.date,
            );
          }
        }
      }
      if (heaviestSet == null && mostReps == null) continue;
      records.add(
        ExercisePersonalRecords(
          name: exerciseGroup.name,
          libraryExerciseId: exerciseGroup.libraryExerciseId,
          normalizedNames: exerciseGroup.normalizedNames,
          heaviestSet: heaviestSet,
          mostReps: mostReps,
        ),
      );
    }

    return records..sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
  }

  /// Finds the record summary that corresponds to [exercise].
  static ExercisePersonalRecords? forExercise(
    List<ExercisePersonalRecords> records,
    Exercise exercise,
  ) {
    final normalizedName = normalizeName(exercise.name);
    final libraryId = exercise.libraryExerciseId;

    if (libraryId != null) {
      for (final record in records) {
        if (record.libraryExerciseId == libraryId) return record;
      }
      for (final record in records) {
        if (record.libraryExerciseId == null &&
            record.normalizedNames.contains(normalizedName)) {
          return record;
        }
      }
      return null;
    }

    for (final record in records) {
      if (record.libraryExerciseId == null &&
          record.normalizedNames.contains(normalizedName)) {
        return record;
      }
    }
    final matchingLibraryRecords = records
        .where((record) => record.normalizedNames.contains(normalizedName))
        .toList();
    return matchingLibraryRecords.length == 1
        ? matchingLibraryRecords.single
        : null;
  }

  /// Normalizes a name for custom/legacy exercise matching.
  static String normalizeName(String name) =>
      ExerciseIdentity.normalizeName(name);
}

bool _isValidSet(WorkoutSet set) =>
    set.reps > 0 && set.weight >= 0 && set.weight.isFinite;
