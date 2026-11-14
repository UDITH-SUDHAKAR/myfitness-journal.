import '../models/meal.dart';

/// Operations for managing meals that have been consumed.
abstract interface class MealRepository {
  /// Saves a meal and returns its database ID.
  Future<int> save(Meal meal);

  /// Returns all meals ordered from newest consumption time to oldest.
  Future<List<Meal>> getAll();

  /// Returns the meal with [id], or null when it does not exist.
  Future<Meal?> getById(int id);

  /// Updates an existing meal, or returns false when it does not exist.
  Future<bool> update(Meal meal);

  /// Deletes a meal and reports whether it existed.
  Future<bool> delete(int id);
}
