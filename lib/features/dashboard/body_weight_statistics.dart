import '../../core/models/body_weight_entry.dart';

/// Helpers for selecting statistics from saved body-weight measurements.
class BodyWeightStatistics {
  const BodyWeightStatistics._();

  /// Returns the entry with the latest date, or null when none are recorded.
  static BodyWeightEntry? latestEntry(List<BodyWeightEntry> entries) {
    if (entries.isEmpty) return null;
    return entries.reduce(
      (latest, entry) => entry.date.isAfter(latest.date) ? entry : latest,
    );
  }
}
