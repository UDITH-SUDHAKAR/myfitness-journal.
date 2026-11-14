import 'exercise.dart';
import 'workout.dart';

/// Read-only performance from the most recent earlier exercise session.
class PreviousPerformance {
  /// Creates a display-only copy of a previous session's sets.
  PreviousPerformance({
    required this.date,
    required List<PreviousPerformanceSet> sets,
  }) : sets = List.unmodifiable(sets);

  /// Date of the workout containing this performance.
  final DateTime date;

  /// Sets copied from the saved workout and safe to display read-only.
  final List<PreviousPerformanceSet> sets;
}

/// Immutable values for a previous set, separate from editable workout sets.
class PreviousPerformanceSet {
  /// Copies the values from one saved workout set.
  const PreviousPerformanceSet({
    required this.weight,
    required this.reps,
    required this.setNumber,
  });

  /// Weight used in the previous session.
  final double weight;

  /// Repetitions completed in the previous session.
  final int reps;

  /// Set position in the previous session.
  final int setNumber;
}

/// Finds the latest earlier workout containing a matching exercise with sets.
///
/// Library IDs are authoritative when both exercises have one. Name matching
/// is used if either ID is missing, which supports custom and older records.
PreviousPerformance? findPreviousPerformance({
  required List<Workout> workouts,
  required Exercise exercise,
  required DateTime beforeDate,
}) {
  final cutoff = DateTime(beforeDate.year, beforeDate.month, beforeDate.day);
  Workout? latestWorkout;
  Exercise? latestExercise;

  for (final workout in workouts) {
    final workoutDay = DateTime(
      workout.date.year,
      workout.date.month,
      workout.date.day,
    );
    if (!workoutDay.isBefore(cutoff)) continue;

    for (final candidate in workout.exercises) {
      if (!_sameExercise(exercise, candidate) || candidate.sets.isEmpty) {
        continue;
      }

      final isMoreRecent =
          latestWorkout == null ||
          workoutDay.isAfter(
            DateTime(
              latestWorkout.date.year,
              latestWorkout.date.month,
              latestWorkout.date.day,
            ),
          ) ||
          (workoutDay ==
                  DateTime(
                    latestWorkout.date.year,
                    latestWorkout.date.month,
                    latestWorkout.date.day,
                  ) &&
              workout.id > latestWorkout.id);

      if (isMoreRecent) {
        latestWorkout = workout;
        latestExercise = candidate;
      }
    }
  }

  if (latestWorkout == null || latestExercise == null) return null;

  final orderedSets = [...latestExercise.sets]
    ..sort((first, second) => first.setNumber.compareTo(second.setNumber));
  return PreviousPerformance(
    date: latestWorkout.date,
    sets: orderedSets
        .map(
          (set) => PreviousPerformanceSet(
            weight: set.weight,
            reps: set.reps,
            setNumber: set.setNumber,
          ),
        )
        .toList(),
  );
}

bool _sameExercise(Exercise current, Exercise previous) {
  final currentId = current.libraryExerciseId;
  final previousId = previous.libraryExerciseId;
  if (currentId != null && previousId != null) {
    return currentId == previousId;
  }

  return _normalizeName(current.name) == _normalizeName(previous.name);
}

String _normalizeName(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
