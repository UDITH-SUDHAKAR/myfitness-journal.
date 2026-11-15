import 'package:myfitness_journal/core/models/meal.dart';
import 'package:myfitness_journal/core/storage/meal_repository.dart';

class FakeMealRepository implements MealRepository {
  FakeMealRepository({List<Meal> meals = const [], this.failLoading = false})
    : _meals = meals.map(_copy).toList();

  final List<Meal> _meals;
  final bool failLoading;
  int _nextId = 1;

  @override
  Future<int> save(Meal meal) async {
    meal.validate();
    meal.id = _nextId++;
    _meals.add(_copy(meal));
    return meal.id;
  }

  @override
  Future<List<Meal>> getAll() async {
    if (failLoading) throw StateError('Meals unavailable');
    return _meals.map(_copy).toList();
  }

  @override
  Future<Meal?> getById(int id) async {
    final matches = _meals.where((meal) => meal.id == id);
    return matches.isEmpty ? null : _copy(matches.first);
  }

  @override
  Future<bool> update(Meal meal) async {
    meal.validate();
    final index = _meals.indexWhere((saved) => saved.id == meal.id);
    if (index < 0) return false;
    _meals[index] = _copy(meal);
    return true;
  }

  @override
  Future<bool> delete(int id) async {
    final index = _meals.indexWhere((meal) => meal.id == id);
    if (index < 0) return false;
    _meals.removeAt(index);
    return true;
  }

  static Meal _copy(Meal meal) => Meal(
    id: meal.id,
    name: meal.name,
    category: meal.category,
    consumedAt: meal.consumedAt,
    items: meal.items
        .map(
          (item) => MealFoodItem(
            foodId: item.foodId,
            foodName: item.foodName,
            servingSize: item.servingSize,
            servingUnit: item.servingUnit,
            caloriesPerServing: item.caloriesPerServing,
            proteinGramsPerServing: item.proteinGramsPerServing,
            carbsGramsPerServing: item.carbsGramsPerServing,
            fatGramsPerServing: item.fatGramsPerServing,
            quantity: item.quantity,
          ),
        )
        .toList(),
  );
}
