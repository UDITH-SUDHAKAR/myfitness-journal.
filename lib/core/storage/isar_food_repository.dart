import 'package:isar_community/isar.dart';

import '../models/food.dart';
import 'food_repository.dart';

/// Isar-backed storage for reusable food definitions.
class IsarFoodRepository implements FoodRepository {
  /// Creates a repository connected to an open Isar database.
  IsarFoodRepository(this._isar);

  final Isar _isar;

  @override
  Future<Id> save(Food food) {
    food.validate();
    return _isar.writeTxn(() => _isar.foods.put(food));
  }

  @override
  Future<List<Food>> getAll() async {
    final foods = await _isar.foods.where().findAll();
    foods.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
    return foods;
  }

  @override
  Future<Food?> getById(Id id) => _isar.foods.get(id);

  @override
  Future<bool> update(Food food) async {
    food.validate();
    return _isar.writeTxn(() async {
      if (await _isar.foods.get(food.id) == null) return false;
      await _isar.foods.put(food);
      return true;
    });
  }

  @override
  Future<bool> delete(Id id) => _isar.writeTxn(() => _isar.foods.delete(id));
}
