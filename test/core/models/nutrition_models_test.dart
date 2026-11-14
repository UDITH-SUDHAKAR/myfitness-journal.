import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/food.dart';
import 'package:myfitness_journal/core/models/meal.dart';

Food makeFood({
  String name = 'Oats',
  double servingSize = 100,
  String servingUnit = 'g',
  double calories = 200,
  double protein = 20,
  double carbs = 30,
  double fats = 10,
}) => Food(
  name: name,
  servingSize: servingSize,
  servingUnit: servingUnit,
  caloriesPerServing: calories,
  proteinGramsPerServing: protein,
  carbsGramsPerServing: carbs,
  fatGramsPerServing: fats,
);

MealFoodItem makeItem({
  int? foodId = 1,
  String name = 'Oats',
  double servingSize = 100,
  String unit = 'g',
  double calories = 200,
  double protein = 20,
  double carbs = 30,
  double fats = 10,
  double quantity = 100,
}) => MealFoodItem(
  foodId: foodId,
  foodName: name,
  servingSize: servingSize,
  servingUnit: unit,
  caloriesPerServing: calories,
  proteinGramsPerServing: protein,
  carbsGramsPerServing: carbs,
  fatGramsPerServing: fats,
  quantity: quantity,
);

void main() {
  group('Food validation', () {
    test('accepts valid nutrition values, including zero', () {
      expect(
        () => makeFood(calories: 0, protein: 0, carbs: 0, fats: 0).validate(),
        returnsNormally,
      );
    });

    test('rejects blank names and units', () {
      expect(() => makeFood(name: '  ').validate(), throwsArgumentError);
      expect(() => makeFood(servingUnit: ' ').validate(), throwsArgumentError);
    });

    test('rejects invalid serving sizes and nutrition values', () {
      for (final size in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          () => makeFood(servingSize: size).validate(),
          throwsArgumentError,
        );
      }
      for (final value in [-1.0, double.nan, double.infinity]) {
        expect(() => makeFood(calories: value).validate(), throwsArgumentError);
      }
    });
  });

  group('MealFoodItem calculations and validation', () {
    test('scales all nutrients for fractional consumed quantities', () {
      final item = makeItem(quantity: 150);

      expect(item.calories, 300);
      expect(item.proteinGrams, 30);
      expect(item.carbsGrams, 45);
      expect(item.fatGrams, 15);
    });

    test('zero nutrition values scale to zero', () {
      final item = makeItem(
        calories: 0,
        protein: 0,
        carbs: 0,
        fats: 0,
        quantity: 25.5,
      );
      item.validate();

      expect(item.calories, 0);
      expect(item.proteinGrams, 0);
      expect(item.carbsGrams, 0);
      expect(item.fatGrams, 0);
    });

    test('rejects invalid names, units, sizes, quantities, and macros', () {
      expect(() => makeItem(name: '').validate(), throwsArgumentError);
      expect(() => makeItem(unit: ' ').validate(), throwsArgumentError);
      expect(() => makeItem(servingSize: 0).validate(), throwsArgumentError);
      expect(() => makeItem(quantity: 0).validate(), throwsArgumentError);
      expect(
        () => makeItem(quantity: double.infinity).validate(),
        throwsArgumentError,
      );
      expect(() => makeItem(fats: -0.1).validate(), throwsArgumentError);
      expect(() => makeItem(carbs: double.nan).validate(), throwsArgumentError);
    });
  });

  group('Meal calculations and validation', () {
    test('sums scaled nutrients across multiple food items', () {
      final meal = Meal(
        name: 'Breakfast',
        consumedAt: DateTime(2026, 11, 14, 8),
        items: [
          makeItem(quantity: 150),
          makeItem(
            name: 'Milk',
            servingSize: 200,
            calories: 100,
            protein: 6,
            carbs: 10,
            fats: 4,
            quantity: 100,
          ),
        ],
      );

      expect(meal.totalCalories, 350);
      expect(meal.totalProteinGrams, 33);
      expect(meal.totalCarbsGrams, 50);
      expect(meal.totalFatGrams, 17);
      expect(meal.validate, returnsNormally);
    });

    test('rejects blank names and meals without food items', () {
      expect(
        () => Meal(
          name: ' ',
          consumedAt: DateTime(2026),
          items: [makeItem()],
        ).validate(),
        throwsArgumentError,
      );
      expect(
        () => Meal(name: 'Snack', consumedAt: DateTime(2026)).validate(),
        throwsArgumentError,
      );
    });
  });
}
