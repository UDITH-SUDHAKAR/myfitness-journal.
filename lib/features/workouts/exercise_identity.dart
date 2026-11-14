import '../../core/models/exercise.dart';
import '../../core/models/workout.dart';

/// One logged occurrence of an exercise and the workout containing it.
class ExerciseLog {
  const ExerciseLog({required this.workout, required this.exercise});

  final Workout workout;
  final Exercise exercise;
}

/// Logged exercises grouped by their stable library ID or custom name.
class ExerciseIdentityGroup {
  ExerciseIdentityGroup._({
    required this.libraryExerciseId,
    required Set<String> normalizedNames,
    required List<ExerciseLog> logs,
    required this.name,
  }) : normalizedNames = Set.unmodifiable(normalizedNames),
       logs = List.unmodifiable(logs);

  final int? libraryExerciseId;
  final Set<String> normalizedNames;
  final List<ExerciseLog> logs;
  final String name;
}

/// Applies the same exercise matching rules wherever workout logs are grouped.
class ExerciseIdentity {
  const ExerciseIdentity._();

  /// Groups library exercises by ID and custom/legacy exercises by name.
  ///
  /// A custom name joins a library group only when exactly one library ID has
  /// that normalized name. Distinct non-null library IDs never merge.
  static List<ExerciseIdentityGroup> groupWorkouts(List<Workout> workouts) {
    final orderedWorkouts = List<Workout>.of(workouts)
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });
    final libraryGroups = <int, _MutableExerciseGroup>{};
    final customGroups = <String, _MutableExerciseGroup>{};

    for (final workout in orderedWorkouts) {
      for (final exercise in workout.exercises) {
        final normalizedName = normalizeName(exercise.name);
        if (normalizedName.isEmpty) continue;
        final libraryId = exercise.libraryExerciseId;
        final group = libraryId == null
            ? customGroups.putIfAbsent(
                normalizedName,
                () => _MutableExerciseGroup(libraryExerciseId: null),
              )
            : libraryGroups.putIfAbsent(
                libraryId,
                () => _MutableExerciseGroup(libraryExerciseId: libraryId),
              );
        group.add(workout, exercise, normalizedName);
      }
    }

    final results = <_MutableExerciseGroup>[...libraryGroups.values];
    for (final entry in customGroups.entries) {
      final matches = libraryGroups.values
          .where((group) => group.normalizedNames.contains(entry.key))
          .toList();
      if (matches.length == 1) {
        matches.single.merge(entry.value);
      } else {
        results.add(entry.value);
      }
    }

    return results.map((group) => group.toImmutable()).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Trims, lowercases, and collapses whitespace in a custom exercise name.
  static String normalizeName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class _MutableExerciseGroup {
  _MutableExerciseGroup({required this.libraryExerciseId});

  final int? libraryExerciseId;
  final Set<String> normalizedNames = {};
  final List<ExerciseLog> logs = [];

  void add(Workout workout, Exercise exercise, String normalizedName) {
    normalizedNames.add(normalizedName);
    logs.add(ExerciseLog(workout: workout, exercise: exercise));
  }

  void merge(_MutableExerciseGroup other) {
    normalizedNames.addAll(other.normalizedNames);
    logs.addAll(other.logs);
  }

  ExerciseIdentityGroup toImmutable() {
    final orderedLogs = List<ExerciseLog>.of(logs)
      ..sort((a, b) {
        final byDate = a.workout.date.compareTo(b.workout.date);
        return byDate != 0 ? byDate : a.workout.id.compareTo(b.workout.id);
      });
    return ExerciseIdentityGroup._(
      libraryExerciseId: libraryExerciseId,
      normalizedNames: normalizedNames,
      logs: orderedLogs,
      name: orderedLogs.isEmpty ? '' : orderedLogs.last.exercise.name.trim(),
    );
  }
}
