import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/features/dashboard/body_weight_statistics.dart';

void main() {
  test('selects the latest dated measurement regardless of list order', () {
    final latest = BodyWeightStatistics.latestEntry([
      BodyWeightEntry(date: DateTime(2026, 11, 12), weightKg: 71),
      BodyWeightEntry(date: DateTime(2026, 11, 14), weightKg: 72),
      BodyWeightEntry(date: DateTime(2026, 11, 13), weightKg: 71.5),
    ]);
    expect(latest?.weightKg, 72);
    expect(latest?.date, DateTime(2026, 11, 14));
  });

  test('returns null when there are no measurements', () {
    expect(BodyWeightStatistics.latestEntry([]), isNull);
  });
}
