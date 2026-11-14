import 'package:isar_community/isar.dart';

/// A body-weight measurement recorded for a calendar date.
part 'body_weight_entry.g.dart';

@collection
class BodyWeightEntry {
  /// Creates an entry. Isar assigns a unique [id] when it is saved.
  BodyWeightEntry({
    this.id = Isar.autoIncrement,
    required this.date,
    required this.weightKg,
  });

  /// Unique database identifier.
  Id id;

  /// Calendar date when the measurement was recorded.
  DateTime date;

  /// Body weight in kilograms.
  double weightKg;
}
