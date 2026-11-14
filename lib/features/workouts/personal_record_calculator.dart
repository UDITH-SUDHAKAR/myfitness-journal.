import '../../core/models/exercise.dart';
import '../../core/models/personal_record.dart';
import '../../core/models/workout.dart';
import '../../core/models/workout_set.dart';

/// Calculates personal bests from saved workouts without persisting them.
class PersonalRecordCalculator {
  /// Builds one record summary per library exercise or custom exercise name.
  ///
  /// A custom or legacy name is merged into a library-ID group only when that
  /// normalized name belongs to exactly one library exercise in the data.
  static List<ExercisePersonalRecords> calculate(
    List<Workout> workouts, {
    int? excludeWorkoutId,
  }) {
    final orderedWorkouts =
        workouts.where((workout) => workout.id != excludeWorkoutId).toList()
          ..sort((first, second) {
            final byDate = first.date.compareTo(second.date);
            return byDate != 0 ? byDate : first.id.compareTo(second.id);
          });

    final libraryGroups = <int, _RecordGroup>{};
    final customGroups = <String, _RecordGroup>{};

    for (final workout in orderedWorkouts) {
      for (final exercise in workout.exercises) {
        final normalizedName = _normalizeName(exercise.name);
        if (normalizedName.isEmpty) continue;

        final libraryId = exercise.libraryExerciseId;
        final group = libraryId == null
            ? customGroups.putIfAbsent(
                normalizedName,
                () => _RecordGroup(libraryExerciseId: null),
              )
            : libraryGroups.putIfAbsent(
                libraryId,
                () => _RecordGroup(libraryExerciseId: libraryId),
              );
        group.addExercise(
          exercise,
          normalizedName: normalizedName,
          date: workout.date,
        );
      }
    }

    final results = <_RecordGroup>[...libraryGroups.values];
    for (final entry in customGroups.entries) {
      final matchingLibraryGroups = libraryGroups.values
          .where((group) => group.normalizedNames.contains(entry.key))
          .toList();

      if (matchingLibraryGroups.length == 1) {
        matchingLibraryGroups.single.merge(entry.value);
      } else {
        // Keep same-name records separate if multiple library IDs make the
        // intended identity unclear.
        results.add(entry.value);
      }
    }

    return results
        .where((group) => group.hasRecords)
        .map((group) => group.toPersonalRecords())
        .toList()
      ..sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );
  }

  /// Finds the record summary that corresponds to [exercise].
  static ExercisePersonalRecords? forExercise(
    List<ExercisePersonalRecords> records,
    Exercise exercise,
  ) {
    final normalizedName = _normalizeName(exercise.name);
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
  static String normalizeName(String name) => _normalizeName(name);
}

class _RecordGroup {
  _RecordGroup({required this.libraryExerciseId});

  final int? libraryExerciseId;
  final Set<String> normalizedNames = {};
  String? _displayName;
  DateTime? _displayNameDate;
  PersonalRecordMark? heaviestSet;
  PersonalRecordMark? mostReps;

  bool get hasRecords => heaviestSet != null || mostReps != null;

  void addExercise(
    Exercise exercise, {
    required String normalizedName,
    required DateTime date,
  }) {
    normalizedNames.add(normalizedName);
    if (_displayNameDate == null || date.isAfter(_displayNameDate!)) {
      _displayName = exercise.name.trim();
      _displayNameDate = date;
    }

    for (final set in exercise.sets) {
      if (!_isValidSet(set)) continue;

      if (set.weight > 0 &&
          (heaviestSet == null || set.weight > heaviestSet!.weight)) {
        heaviestSet = PersonalRecordMark(
          weight: set.weight,
          reps: set.reps,
          date: date,
        );
      }
      if (mostReps == null || set.reps > mostReps!.reps) {
        mostReps = PersonalRecordMark(
          weight: set.weight,
          reps: set.reps,
          date: date,
        );
      }
    }
  }

  void merge(_RecordGroup other) {
    normalizedNames.addAll(other.normalizedNames);
    if (other._displayNameDate != null &&
        (_displayNameDate == null ||
            other._displayNameDate!.isAfter(_displayNameDate!))) {
      _displayName = other._displayName;
      _displayNameDate = other._displayNameDate;
    }
    heaviestSet = _mergeMark(
      heaviestSet,
      other.heaviestSet,
      compare: (a, b) => a.weight.compareTo(b.weight),
    );
    mostReps = _mergeMark(
      mostReps,
      other.mostReps,
      compare: (a, b) => a.reps.compareTo(b.reps),
    );
  }

  ExercisePersonalRecords toPersonalRecords() => ExercisePersonalRecords(
    name: _displayName ?? '',
    libraryExerciseId: libraryExerciseId,
    normalizedNames: normalizedNames,
    heaviestSet: heaviestSet,
    mostReps: mostReps,
  );
}

PersonalRecordMark? _mergeMark(
  PersonalRecordMark? first,
  PersonalRecordMark? second, {
  required int Function(PersonalRecordMark, PersonalRecordMark) compare,
}) {
  if (first == null) return second;
  if (second == null) return first;
  final comparison = compare(first, second);
  if (comparison > 0) return first;
  if (comparison < 0) return second;
  return first.date.isBefore(second.date) ? first : second;
}

bool _isValidSet(WorkoutSet set) =>
    set.reps > 0 && set.weight >= 0 && set.weight.isFinite;

String _normalizeName(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
