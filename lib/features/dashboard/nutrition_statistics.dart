import '../../core/models/meal.dart';
import '../../core/models/nutrition_entry.dart';

/// Daily nutrition totals summed from saved entries.
class DailyNutritionTotals {
  const DailyNutritionTotals({
    required this.calories,
    required this.proteinGrams,
  });

  final double calories;
  final double proteinGrams;
}

/// Calculates nutrition totals for one calendar day.
class NutritionStatisticsCalculator {
  const NutritionStatisticsCalculator._();

  static DailyNutritionTotals forDate({
    required List<NutritionEntry> entries,
    required DateTime date,
    List<Meal> meals = const [],
  }) {
    final matchingEntries = entries.where(
      (entry) => _sameDay(entry.date, date),
    );
    final matchingMeals = meals.where(
      (meal) => _sameDay(meal.consumedAt, date),
    );
    return DailyNutritionTotals(
      calories:
          matchingEntries.fold<double>(
            0,
            (sum, entry) => sum + entry.calories,
          ) +
          matchingMeals.fold<double>(
            0,
            (sum, meal) => sum + meal.totalCalories,
          ),
      proteinGrams:
          matchingEntries.fold<double>(
            0,
            (sum, entry) => sum + entry.proteinGrams,
          ) +
          matchingMeals.fold<double>(
            0,
            (sum, meal) => sum + meal.totalProteinGrams,
          ),
    );
  }

  static bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
