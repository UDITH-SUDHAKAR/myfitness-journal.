import 'package:myfitness_journal/core/models/nutrition_entry.dart';
import 'package:myfitness_journal/core/storage/nutrition_repository.dart';

class FakeNutritionRepository implements NutritionRepository {
  final List<NutritionEntry> _entries = [];
  int _nextId = 1;

  @override
  Future<int> save(NutritionEntry entry) async {
    entry.id = _nextId++;
    _entries.add(_copy(entry));
    return entry.id;
  }

  @override
  Future<List<NutritionEntry>> getAll() async => _entries.map(_copy).toList();

  @override
  Future<bool> update(NutritionEntry entry) async {
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

  NutritionEntry _copy(NutritionEntry entry) => NutritionEntry(
    id: entry.id,
    date: entry.date,
    name: entry.name,
    calories: entry.calories,
    proteinGrams: entry.proteinGrams,
  );
}
