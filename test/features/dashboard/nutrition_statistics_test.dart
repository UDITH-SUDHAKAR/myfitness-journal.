import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/nutrition_entry.dart';
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
}
