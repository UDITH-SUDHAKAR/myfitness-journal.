import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/nutrition_entry.dart';
import 'package:myfitness_journal/core/models/meal.dart';
import 'package:myfitness_journal/features/dashboard/nutrition_statistics.dart';

void main() {
  test('sums multiple entries for a calendar day and ignores other days', () {
    final totals = NutritionStatisticsCalculator.forDate(
      date: DateTime(2026, 11, 14),
      entries: [
        NutritionEntry(
          date: DateTime(2026, 11, 14, 8),
          name: 'Breakfast',
          calories: 400,
          proteinGrams: 22.5,
        ),
        NutritionEntry(
          date: DateTime(2026, 11, 14, 20),
          name: 'Dinner',
          calories: 700,
          proteinGrams: 31,
        ),
        NutritionEntry(
          date: DateTime(2026, 11, 15),
          name: 'Tomorrow',
          calories: 1200,
          proteinGrams: 60,
        ),
      ],
    );

    expect(totals.calories, 1100);
    expect(totals.proteinGrams, 53.5);
  });

  test('returns zero totals when the day has no entries', () {
    final totals = NutritionStatisticsCalculator.forDate(
      entries: [],
      date: DateTime(2026, 11, 14),
    );
    expect(totals.calories, 0);
    expect(totals.proteinGrams, 0);
  });

  test('combines legacy entries with meal totals once per calendar date', () {
    final totals = NutritionStatisticsCalculator.forDate(
      entries: [
        NutritionEntry(
          date: DateTime(2026, 11, 14, 8),
          name: 'Legacy breakfast',
          calories: 100,
          proteinGrams: 5,
        ),
      ],
      meals: [
        Meal(
          name: 'Lunch',
          category: 'Lunch',
          consumedAt: DateTime(2026, 11, 14, 23),
          items: [
            MealFoodItem(
              foodName: 'Rice',
              servingSize: 100,
              servingUnit: 'g',
              caloriesPerServing: 130,
              proteinGramsPerServing: 3,
              carbsGramsPerServing: 28,
              fatGramsPerServing: 1,
              quantity: 150,
            ),
          ],
        ),
        Meal(
          name: 'Other day',
          consumedAt: DateTime(2026, 11, 15),
          items: [
            MealFoodItem(
              foodName: 'Rice',
              servingSize: 100,
              servingUnit: 'g',
              caloriesPerServing: 130,
              proteinGramsPerServing: 3,
              quantity: 100,
            ),
          ],
        ),
      ],
      date: DateTime(2026, 11, 14),
    );

    expect(totals.calories, 295);
    expect(totals.proteinGrams, 9.5);
  });
}
