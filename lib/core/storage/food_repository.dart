import '../models/food.dart';

/// Operations for managing reusable food definitions.
abstract interface class FoodRepository {
  /// Saves a new food and returns its database ID.
  Future<int> save(Food food);

  /// Returns all saved foods ordered by name.
  Future<List<Food>> getAll();

  /// Finds foods whose names contain [query], ignoring case and surrounding
  /// whitespace. An empty query returns all foods.
  Future<List<Food>> searchByName(String query);

  /// Returns the food with [id], or null when it does not exist.
  Future<Food?> getById(int id);

  /// Updates an existing food, or returns false when it does not exist.
  Future<bool> update(Food food);

  /// Deletes a food and reports whether it existed.
  Future<bool> delete(int id);
}
