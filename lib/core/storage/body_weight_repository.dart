import '../models/body_weight_entry.dart';

/// Operations for saving and reading daily body-weight entries.
abstract interface class BodyWeightRepository {
  /// Saves an entry, replacing an existing entry for the same calendar date.
  Future<int> save(BodyWeightEntry entry);

  /// Returns all entries ordered from newest date to oldest.
  Future<List<BodyWeightEntry>> getAll();

  /// Updates an existing entry, or returns false when it no longer exists.
  Future<bool> update(BodyWeightEntry entry);

  /// Deletes an entry and reports whether it existed.
  Future<bool> delete(int id);
}
