import 'package:isar_community/isar.dart';

/// A reusable exercise description stored independently from workout logs.
part 'exercise_library_item.g.dart';

@collection
class ExerciseLibraryItem {
  /// Creates a library item. Isar assigns [id] when it is saved.
  ExerciseLibraryItem({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.description,
  });

  /// Unique database ID.
  Id id;

  /// Exercise name shown in the library and picker.
  @Index(type: IndexType.value)
  String name;

  /// Main muscle group or category, stored as flexible text.
  String muscleGroup;

  /// Equipment needed, stored as flexible text.
  String equipment;

  /// Optional instructions or description.
  String? description;
}
