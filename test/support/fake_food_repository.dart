import 'package:myfitness_journal/core/models/food.dart';
import 'package:myfitness_journal/core/storage/food_repository.dart';

class FakeFoodRepository implements FoodRepository {
  FakeFoodRepository({List<Food> foods = const [], this.failLoading = false})
    : _foods = foods.map(_copy).toList();

  final List<Food> _foods;
  final bool failLoading;
  int _nextId = 1;

  @override
  Future<int> save(Food food) async {
    food.validate();
    food.id = _nextId++;
    _foods.add(_copy(food));
    return food.id;
  }

  @override
  Future<List<Food>> getAll() async {
    if (failLoading) throw StateError('Foods unavailable');
    return _foods.map(_copy).toList();
  }

  @override
  Future<List<Food>> searchByName(String query) async {
    if (failLoading) throw StateError('Foods unavailable');
    final normalized = query.trim().toLowerCase();
    return (normalized.isEmpty
            ? _foods
            : _foods.where(
                (food) => food.name.toLowerCase().contains(normalized),
              ))
        .map(_copy)
        .toList();
  }

  @override
  Future<Food?> getById(int id) async {
    final matches = _foods.where((food) => food.id == id);
    return matches.isEmpty ? null : _copy(matches.first);
  }

  @override
  Future<bool> update(Food food) async {
    food.validate();
    final index = _foods.indexWhere((saved) => saved.id == food.id);
    if (index < 0) return false;
    _foods[index] = _copy(food);
    return true;
  }

  @override
  Future<bool> delete(int id) async {
    final index = _foods.indexWhere((food) => food.id == id);
    if (index < 0) return false;
    _foods.removeAt(index);
    return true;
  }

  static Food _copy(Food food) => Food(
    id: food.id,
    name: food.name,
    servingSize: food.servingSize,
    servingUnit: food.servingUnit,
    caloriesPerServing: food.caloriesPerServing,
    proteinGramsPerServing: food.proteinGramsPerServing,
    carbsGramsPerServing: food.carbsGramsPerServing,
    fatGramsPerServing: food.fatGramsPerServing,
  );
}
