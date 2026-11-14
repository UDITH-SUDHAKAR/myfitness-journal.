import 'package:isar_community/isar.dart';

import '../models/meal.dart';
import 'meal_repository.dart';

/// Isar-backed storage for consumed meals and their food snapshots.
class IsarMealRepository implements MealRepository {
  /// Creates a repository connected to an open Isar database.
  IsarMealRepository(this._isar);

  final Isar _isar;

  @override
  Future<Id> save(Meal meal) {
    meal.validate();
    return _isar.writeTxn(() => _isar.meals.put(meal));
  }

  @override
  Future<List<Meal>> getAll() async {
    final meals = await _isar.meals.where().findAll();
    meals.sort(
      (first, second) => second.consumedAt.compareTo(first.consumedAt),
    );
    return meals;
  }

  @override
  Future<Meal?> getById(Id id) => _isar.meals.get(id);

  @override
  Future<bool> update(Meal meal) async {
    meal.validate();
    return _isar.writeTxn(() async {
      if (await _isar.meals.get(meal.id) == null) return false;
      await _isar.meals.put(meal);
      return true;
    });
  }

  @override
  Future<bool> delete(Id id) => _isar.writeTxn(() => _isar.meals.delete(id));
}
