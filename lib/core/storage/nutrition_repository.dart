import '../models/nutrition_entry.dart';

/// Operations for saving and reading food entries used in daily summaries.
abstract interface class NutritionRepository {
  /// Saves a new food or meal entry and returns its database ID.
  Future<int> save(NutritionEntry entry);

  /// Returns all saved nutrition entries.
  Future<List<NutritionEntry>> getAll();

  /// Updates an existing entry, or returns false when it no longer exists.
  Future<bool> update(NutritionEntry entry);

  /// Deletes an entry and reports whether it existed.
  Future<bool> delete(int id);
}
