import 'package:isar_community/isar.dart';

/// One named food or meal entry with its calorie and protein values.
part 'nutrition_entry.g.dart';

@collection
class NutritionEntry {
  /// Creates an entry. Isar assigns a unique [id] when it is saved.
  NutritionEntry({
    this.id = Isar.autoIncrement,
    required this.date,
    required this.name,
    required this.calories,
    required this.proteinGrams,
  });

  /// Unique database identifier.
  Id id;

  /// Calendar date when the food or meal was consumed.
  DateTime date;

  /// Name shown in the daily food log.
  String name;

  /// Calories recorded for this entry.
  int calories;

  /// Protein recorded for this entry, in grams.
  double proteinGrams;
}
