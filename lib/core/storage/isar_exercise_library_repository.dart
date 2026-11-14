import 'package:isar_community/isar.dart';

import '../models/exercise_library_item.dart';
import 'exercise_library_repository.dart';

/// Isar-backed storage for reusable exercise descriptions.
class IsarExerciseLibraryRepository implements ExerciseLibraryRepository {
  /// Creates a repository connected to an open Isar database.
  IsarExerciseLibraryRepository(this._isar);

  final Isar _isar;

  @override
  Future<Id> save(ExerciseLibraryItem item) =>
      _isar.writeTxn(() => _isar.exerciseLibraryItems.put(item));

  @override
  Future<List<ExerciseLibraryItem>> search(String query) async {
    final items = await _isar.exerciseLibraryItems.where().findAll();
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return items;
    return items
        .where((item) => item.name.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  @override
  Future<bool> update(ExerciseLibraryItem item) async {
    return _isar.writeTxn(() async {
      if (await _isar.exerciseLibraryItems.get(item.id) == null) return false;
      await _isar.exerciseLibraryItems.put(item);
      return true;
    });
  }

  @override
  Future<bool> delete(Id id) =>
      _isar.writeTxn(() => _isar.exerciseLibraryItems.delete(id));
}
