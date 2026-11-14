import '../../core/models/nutrition_entry.dart';

/// Daily nutrition totals summed from saved entries.
class DailyNutritionTotals {
  const DailyNutritionTotals({
    required this.calories,
    required this.proteinGrams,
  });

  final int calories;
  final double proteinGrams;
}

/// Calculates nutrition totals for one calendar day.
class NutritionStatisticsCalculator {
  const NutritionStatisticsCalculator._();

  static DailyNutritionTotals forDate({
    required List<NutritionEntry> entries,
    required DateTime date,
  }) {
    final matchingEntries = entries.where(
      (entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day,
    );
    return DailyNutritionTotals(
      calories: matchingEntries.fold(0, (sum, entry) => sum + entry.calories),
      proteinGrams: matchingEntries.fold(
        0,
        (sum, entry) => sum + entry.proteinGrams,
      ),
    );
  }
}
