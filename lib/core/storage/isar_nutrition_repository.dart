import 'package:isar_community/isar.dart';

import '../models/nutrition_entry.dart';
import 'nutrition_repository.dart';

/// Isar-backed storage for food and meal nutrition entries.
class IsarNutritionRepository implements NutritionRepository {
  /// Creates a repository connected to an open Isar database.
  IsarNutritionRepository(this._isar);

  final Isar _isar;

  @override
  Future<Id> save(NutritionEntry entry) =>
      _isar.writeTxn(() => _isar.nutritionEntrys.put(entry));

  @override
  Future<List<NutritionEntry>> getAll() async {
    final entries = await _isar.nutritionEntrys.where().findAll();
    entries.sort((first, second) {
      final byDate = second.date.compareTo(first.date);
      return byDate != 0 ? byDate : second.id.compareTo(first.id);
    });
    return entries;
  }

  @override
  Future<bool> update(NutritionEntry entry) async {
    return _isar.writeTxn(() async {
      if (await _isar.nutritionEntrys.get(entry.id) == null) return false;
      await _isar.nutritionEntrys.put(entry);
      return true;
    });
  }

  @override
  Future<bool> delete(Id id) =>
      _isar.writeTxn(() => _isar.nutritionEntrys.delete(id));
}
