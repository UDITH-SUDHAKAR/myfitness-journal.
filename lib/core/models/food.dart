import 'package:isar_community/isar.dart';

/// A reusable food definition with nutrition values for one serving.
part 'food.g.dart';

@collection
class Food {
  /// Creates a food. Isar assigns [id] when the food is first saved.
  Food({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.servingSize,
    required this.servingUnit,
    required this.caloriesPerServing,
    required this.proteinGramsPerServing,
    required this.carbsGramsPerServing,
    required this.fatGramsPerServing,
  });

  /// Unique database identifier.
  Id id;

  /// Name displayed for this reusable food.
  String name;

  /// Amount represented by the nutrition values for one serving.
  double servingSize;

  /// Unit for [servingSize], such as `g`, `ml`, or `piece`.
  String servingUnit;

  /// Calories in one serving.
  double caloriesPerServing;

  /// Protein grams in one serving.
  double proteinGramsPerServing;

  /// Carbohydrate grams in one serving.
  double carbsGramsPerServing;

  /// Fat grams in one serving.
  double fatGramsPerServing;

  /// Throws [ArgumentError] if any food data is invalid.
  ///
  /// Call this before saving so validation also runs in release builds.
  void validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Food name cannot be blank.');
    }
    if (!servingSize.isFinite || servingSize <= 0) {
      throw ArgumentError.value(
        servingSize,
        'servingSize',
        'Serving size must be a finite positive number.',
      );
    }
    if (servingUnit.trim().isEmpty) {
      throw ArgumentError.value(
        servingUnit,
        'servingUnit',
        'Serving unit cannot be blank.',
      );
    }
    _validateNutrition('caloriesPerServing', caloriesPerServing);
    _validateNutrition('proteinGramsPerServing', proteinGramsPerServing);
    _validateNutrition('carbsGramsPerServing', carbsGramsPerServing);
    _validateNutrition('fatGramsPerServing', fatGramsPerServing);
  }

  static void _validateNutrition(String field, double value) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(
        value,
        field,
        'Nutrition values must be finite and non-negative.',
      );
    }
  }
}
