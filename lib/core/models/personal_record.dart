/// A single best set and the workout date when it was recorded.
class PersonalRecordMark {
  /// Creates a personal-record value for one workout set.
  const PersonalRecordMark({
    required this.weight,
    required this.reps,
    required this.date,
  });

  /// Weight recorded for the set, in kilograms.
  final double weight;

  /// Repetitions completed in the set.
  final int reps;

  /// Date of the workout containing the set.
  final DateTime date;
}

/// The best saved performances for one identifiable exercise.
class ExercisePersonalRecords {
  /// Creates a calculated record summary; it is not persisted in Isar.
  ExercisePersonalRecords({
    required this.name,
    required this.libraryExerciseId,
    required Set<String> normalizedNames,
    required this.heaviestSet,
    required this.mostReps,
  }) : normalizedNames = Set.unmodifiable(normalizedNames);

  /// Most recently used exercise-name snapshot for display.
  final String name;

  /// Library identity, or `null` for custom and legacy exercises.
  final int? libraryExerciseId;

  /// Normalized name snapshots used to associate legacy/custom logs.
  final Set<String> normalizedNames;

  /// Highest positive weight recorded for this exercise.
  final PersonalRecordMark? heaviestSet;

  /// Highest rep count recorded, including sets with zero weight.
  final PersonalRecordMark? mostReps;

  /// Whether at least one calculated record exists.
  bool get hasRecords => heaviestSet != null || mostReps != null;
}
