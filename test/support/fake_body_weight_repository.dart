import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/core/storage/body_weight_repository.dart';

class FakeBodyWeightRepository implements BodyWeightRepository {
  final List<BodyWeightEntry> _entries = [];
  int _nextId = 1;

  @override
  Future<int> save(BodyWeightEntry entry) async {
    final sameDayIndex = _entries.indexWhere(
      (saved) =>
          saved.date.year == entry.date.year &&
          saved.date.month == entry.date.month &&
          saved.date.day == entry.date.day,
    );
    if (sameDayIndex >= 0) {
      entry.id = _entries[sameDayIndex].id;
      _entries[sameDayIndex] = _copy(entry);
    } else {
      entry.id = _nextId++;
      _entries.add(_copy(entry));
    }
    return entry.id;
  }

  @override
  Future<List<BodyWeightEntry>> getAll() async =>
      _entries.map(_copy).toList()..sort((a, b) => b.date.compareTo(a.date));

  @override
  Future<bool> update(BodyWeightEntry entry) async {
    final index = _entries.indexWhere((saved) => saved.id == entry.id);
    if (index < 0) return false;
    _entries[index] = _copy(entry);
    return true;
  }

  @override
  Future<bool> delete(int id) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index < 0) return false;
    _entries.removeAt(index);
    return true;
  }

  BodyWeightEntry _copy(BodyWeightEntry entry) =>
      BodyWeightEntry(id: entry.id, date: entry.date, weightKg: entry.weightKg);
}
