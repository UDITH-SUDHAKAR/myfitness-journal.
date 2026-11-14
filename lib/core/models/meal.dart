import 'package:isar_community/isar.dart';

/// A consumed meal and the food portions that made it up.
part 'meal.g.dart';

@collection
class Meal {
  /// Creates a meal. Isar assigns [id] when the meal is first saved.
  Meal({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.consumedAt,
    this.items = const [],
  });

  /// Unique database identifier.
  Id id;

  /// Name for this meal, such as `Breakfast`.
  String name;

  /// Date and time when the meal was consumed.
  DateTime consumedAt;

  /// Food portions recorded as snapshots inside this meal.
  List<MealFoodItem> items;

  /// Total calories in all items, scaled to each consumed quantity.
  double get totalCalories => _total((item) => item.calories);

  /// Total protein grams in all items, scaled to each consumed quantity.
  double get totalProteinGrams => _total((item) => item.proteinGrams);

  /// Total carbohydrate grams in all items, scaled to each consumed quantity.
  double get totalCarbsGrams => _total((item) => item.carbsGrams);

  /// Total fat grams in all items, scaled to each consumed quantity.
  double get totalFatGrams => _total((item) => item.fatGrams);

  /// Throws [ArgumentError] when the meal has no name or food items.
  void validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Meal name cannot be blank.');
    }
    if (items.isEmpty) {
      throw ArgumentError.value(
        items,
        'items',
        'A meal must contain at least one food item.',
      );
    }
    for (final item in items) {
      item.validate();
    }
    // Validate the totals as well, guarding against overflow in arithmetic.
    _total((item) => item.calories);
    _total((item) => item.proteinGrams);
    _total((item) => item.carbsGrams);
    _total((item) => item.fatGrams);
  }

  double _total(double Function(MealFoodItem) valueFor) {
    return items.fold<double>(0, (sum, item) {
      // The MealFoodItem getters already scale their per-serving values.
      final value = valueFor(item);
      final total = sum + value;
      if (!total.isFinite) {
        throw ArgumentError('Meal nutrition totals must remain finite.');
      }
      return total;
    });
  }
}

/// A consumed amount of a food, with a historical nutrition snapshot.
///
/// The snapshot means editing or deleting a reusable [Food] never changes a
/// saved meal. Quantity and serving size use the same unit.
@embedded
class MealFoodItem {
  /// Creates an embedded item. Defaults allow Isar to deserialize it safely.
  MealFoodItem({
    this.foodId,
    this.foodName = '',
    this.servingSize = 0,
    this.servingUnit = '',
    this.caloriesPerServing = 0,
    this.proteinGramsPerServing = 0,
    this.carbsGramsPerServing = 0,
    this.fatGramsPerServing = 0,
    this.quantity = 0,
  });

  /// ID of the source Food definition, if this item came from the library.
  int? foodId;

  /// Name of the food when it was added to the meal.
  String foodName;

  /// Serving size used for the saved nutrition snapshot.
  double servingSize;

  /// Unit shared by [servingSize] and [quantity].
  String servingUnit;

  /// Calories in the snapshot serving size.
  double caloriesPerServing;

  /// Protein grams in the snapshot serving size.
  double proteinGramsPerServing;

  /// Carbohydrate grams in the snapshot serving size.
  double carbsGramsPerServing;

  /// Fat grams in the snapshot serving size.
  double fatGramsPerServing;

  /// Amount consumed, expressed in [servingUnit].
  double quantity;

  /// Calories consumed after scaling to [quantity].
  double get calories => _scaled(caloriesPerServing);

  /// Protein grams consumed after scaling to [quantity].
  double get proteinGrams => _scaled(proteinGramsPerServing);

  /// Carbohydrate grams consumed after scaling to [quantity].
  double get carbsGrams => _scaled(carbsGramsPerServing);

  /// Fat grams consumed after scaling to [quantity].
  double get fatGrams => _scaled(fatGramsPerServing);

  /// Throws [ArgumentError] when the snapshot or consumed amount is invalid.
  void validate() {
    if (foodName.trim().isEmpty) {
      throw ArgumentError.value(
        foodName,
        'foodName',
        'Food name cannot be blank.',
      );
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
    if (!quantity.isFinite || quantity <= 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'Quantity must be a finite positive number.',
      );
    }
    for (final value in [
      caloriesPerServing,
      proteinGramsPerServing,
      carbsGramsPerServing,
      fatGramsPerServing,
    ]) {
      if (!value.isFinite || value < 0) {
        throw ArgumentError.value(
          value,
          'nutritionPerServing',
          'Nutrition values must be finite and non-negative.',
        );
      }
    }
    _scaled(caloriesPerServing);
    _scaled(proteinGramsPerServing);
    _scaled(carbsGramsPerServing);
    _scaled(fatGramsPerServing);
  }

  double _scaled(double valuePerServing) {
    final multiplier = quantity / servingSize;
    final result = valuePerServing * multiplier;
    if (!multiplier.isFinite || !result.isFinite) {
      throw ArgumentError('Scaled nutrition values must remain finite.');
    }
    return result;
  }
}
