import 'package:isar_community/isar.dart';

import '../models/body_weight_entry.dart';
import 'body_weight_repository.dart';

/// Isar-backed storage for body-weight measurements.
class IsarBodyWeightRepository implements BodyWeightRepository {
  /// Creates a repository connected to an open Isar database.
  IsarBodyWeightRepository(this._isar);

  final Isar _isar;

  @override
  Future<Id> save(BodyWeightEntry entry) async {
    return _isar.writeTxn(() async {
      final entries = await _isar.bodyWeightEntrys.where().findAll();
      final sameDate = entries.where(
        (saved) => _sameDay(saved.date, entry.date),
      );
      if (sameDate.isNotEmpty) {
        entry.id = sameDate.first.id;
      }
      return _isar.bodyWeightEntrys.put(entry);
    });
  }

  @override
  Future<List<BodyWeightEntry>> getAll() async {
    final entries = await _isar.bodyWeightEntrys.where().findAll();
    entries.sort((first, second) => second.date.compareTo(first.date));
    return entries;
  }

  @override
  Future<bool> update(BodyWeightEntry entry) async {
    return _isar.writeTxn(() async {
      if (await _isar.bodyWeightEntrys.get(entry.id) == null) return false;
      final entries = await _isar.bodyWeightEntrys.where().findAll();
      final dateAlreadyUsed = entries.any(
        (saved) => saved.id != entry.id && _sameDay(saved.date, entry.date),
      );
      if (dateAlreadyUsed) return false;
      await _isar.bodyWeightEntrys.put(entry);
      return true;
    });
  }

  @override
  Future<bool> delete(Id id) =>
      _isar.writeTxn(() => _isar.bodyWeightEntrys.delete(id));

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
