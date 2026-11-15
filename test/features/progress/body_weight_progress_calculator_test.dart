import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/features/progress/body_weight_progress_calculator.dart';

void main() {
  group('BodyWeightProgressCalculator.forWeeks', () {
    test('uses 12 Monday-based weeks and includes the reference date', () {
      final progress = BodyWeightProgressCalculator.forWeeks(
        referenceDate: DateTime(2026, 1, 1, 23, 59), // Thursday.
        entries: [
          _entry(DateTime(2025, 10, 12), 69), // Before the first Monday.
          _entry(DateTime(2025, 10, 13, 18), 70), // First included day.
          _entry(DateTime(2025, 12, 31, 8), 71),
          _entry(DateTime(2026, 1, 1, 23, 59), 72), // Reference day included.
          _entry(DateTime(2026, 1, 2), 73), // After the reference day.
        ],
      );

      expect(progress.startDate, DateTime(2025, 10, 13));
      expect(progress.endDate, DateTime(2026, 1, 1));
      expect(progress.entries.map((entry) => entry.weightKg), [70, 71, 72]);
    });
  });

  group('BodyWeightProgressCalculator.forMonths', () {
    test('uses calendar months and handles year transitions', () {
      final progress = BodyWeightProgressCalculator.forMonths(
        referenceDate: DateTime(2026, 1, 1, 21),
        entries: [
          _entry(DateTime(2025, 1, 31), 69), // Before the 12-month window.
          _entry(DateTime(2025, 2, 1), 70), // First included date.
          _entry(DateTime(2025, 12, 31), 71),
          _entry(DateTime(2026, 1, 1, 23), 72), // Reference day included.
          _entry(DateTime(2026, 1, 2), 73),
        ],
      );

      expect(progress.startDate, DateTime(2025, 2, 1));
      expect(progress.endDate, DateTime(2026, 1, 1));
      expect(progress.entries.map((entry) => entry.weightKg), [70, 71, 72]);
    });
  });

  test('sorts entries and reports first, latest, and absolute change', () {
    final progress = BodyWeightProgressCalculator.forWeeks(
      referenceDate: DateTime(2026, 5, 20),
      entries: [
        _entry(DateTime(2026, 5, 20), 68.5),
        _entry(DateTime(2026, 5, 1), 70),
      ],
    );

    expect(progress.firstEntry?.weightKg, 70);
    expect(progress.latestEntry?.weightKg, 68.5);
    expect(progress.absoluteChangeKg, 1.5);
    expect(progress.increased, isFalse);
  });

  test('empty windows have no summary values', () {
    final progress = BodyWeightProgressCalculator.forMonths(
      referenceDate: DateTime(2026, 6, 15),
      entries: [],
    );

    expect(progress.entries, isEmpty);
    expect(progress.firstEntry, isNull);
    expect(progress.latestEntry, isNull);
    expect(progress.absoluteChangeKg, isNull);
  });

  test('single-entry windows show the entry but no change', () {
    final progress = BodyWeightProgressCalculator.forMonths(
      referenceDate: DateTime(2026, 6, 15),
      entries: [_entry(DateTime(2026, 6, 10), 72.4)],
    );

    expect(progress.firstEntry?.weightKg, 72.4);
    expect(progress.latestEntry?.weightKg, 72.4);
    expect(progress.absoluteChangeKg, isNull);
  });

  test('ignores invalid and out-of-window values', () {
    final progress = BodyWeightProgressCalculator.forWeeks(
      referenceDate: DateTime(2026, 6, 17),
      entries: [
        _entry(DateTime(2026, 6, 10), double.nan),
        _entry(DateTime(2026, 6, 11), double.infinity),
        _entry(DateTime(2026, 6, 12), -1),
        _entry(DateTime(2026, 1, 1), 70),
      ],
    );

    expect(progress.entries, isEmpty);
  });
}

BodyWeightEntry _entry(DateTime date, double weight) =>
    BodyWeightEntry(date: date, weightKg: weight);
