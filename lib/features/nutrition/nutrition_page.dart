import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/food.dart';
import '../../core/models/meal.dart';
import '../../core/models/nutrition_entry.dart';
import '../../core/storage/food_repository.dart';
import '../../core/storage/meal_repository.dart';
import '../../core/storage/nutrition_repository.dart';
import '../dashboard/nutrition_statistics.dart';
import 'food_entry_dialog.dart';

/// Logs meals from the food library and preserves older nutrition entries.
class NutritionPage extends StatefulWidget {
  const NutritionPage({
    required this.repository,
    required this.foodRepository,
    required this.mealRepository,
    required this.selectedDate,
    required this.onEntriesChanged,
    required this.onMealsChanged,
    required this.onLoadFinished,
    super.key,
  });

  /// Repository for nutrition entries saved before meal logging was added.
  final NutritionRepository repository;

  /// Repository for reusable food definitions.
  final FoodRepository foodRepository;

  /// Repository for newly logged meals.
  final MealRepository mealRepository;

  /// Date currently selected by the app's shared date controls.
  final DateTime selectedDate;

  /// Reports the latest legacy entry list to the dashboard.
  final ValueChanged<List<NutritionEntry>> onEntriesChanged;

  /// Reports the latest meal list to the dashboard.
  final ValueChanged<List<Meal>> onMealsChanged;

  /// Reports whether nutrition data loaded successfully.
  final ValueChanged<bool> onLoadFinished;

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  static const _categories = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  final _legacyNameController = TextEditingController();
  final _legacyCaloriesController = TextEditingController();
  final _legacyProteinController = TextEditingController();
  final _foodSearchController = TextEditingController();
  List<NutritionEntry> _entries = [];
  List<Meal> _meals = [];
  List<Food> _searchResults = [];
  final List<_SelectedFood> _selectedFoods = [];
  String _selectedCategory = _categories.first;
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;
  String? _searchError;
  int _searchRequest = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _legacyNameController.dispose();
    _legacyCaloriesController.dispose();
    _legacyProteinController.dispose();
    _foodSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    var loadSucceeded = true;
    try {
      _entries = await widget.repository.getAll();
    } catch (error) {
      loadSucceeded = false;
      _error = error.toString();
    }
    try {
      _meals = await widget.mealRepository.getAll();
    } catch (error) {
      loadSucceeded = false;
      _error ??= error.toString();
    }
    try {
      final foods = await widget.foodRepository.getAll();
      _searchResults = _filterFoods(foods, _foodSearchController.text);
    } catch (error) {
      loadSucceeded = false;
      _error ??= error.toString();
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    widget.onEntriesChanged(List.unmodifiable(_entries));
    widget.onMealsChanged(List.unmodifiable(_meals));
    widget.onLoadFinished(loadSucceeded);
  }

  List<NutritionEntry> get _entriesForSelectedDate => _entries
      .where((entry) => DateUtils.isSameDay(entry.date, widget.selectedDate))
      .toList();

  List<Meal> get _mealsForSelectedDate => _meals
      .where(
        (meal) => DateUtils.isSameDay(meal.consumedAt, widget.selectedDate),
      )
      .toList();

  DailyNutritionTotals get _dailyTotals =>
      NutritionStatisticsCalculator.forDate(
        entries: _entries,
        meals: _meals,
        date: widget.selectedDate,
      );

  List<Food> _filterFoods(List<Food> foods, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return foods;
    return foods
        .where((food) => food.name.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  Future<void> _searchFoods(String query) async {
    final request = ++_searchRequest;
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final foods = await widget.foodRepository.searchByName(query);
      if (!mounted || request != _searchRequest) return;
      setState(() {
        _searchResults = foods;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted || request != _searchRequest) return;
      setState(() {
        _isSearching = false;
        _searchError = error.toString();
      });
    }
  }

  Future<void> _createFood() async {
    final food = await showDialog<Food>(
      context: context,
      builder: (context) => const FoodEntryDialog(),
    );
    if (food == null) return;
    try {
      await widget.foodRepository.save(food);
      _foodSearchController.text = food.name;
      await _searchFoods(food.name);
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not save food: $error');
    }
  }

  void _selectFood(Food food) {
    setState(() {
      _selectedFoods.add(
        _SelectedFood(food: food, quantityText: food.servingSize.toString()),
      );
      _error = null;
    });
  }

  Future<void> _saveMeal() async {
    if (_selectedFoods.isEmpty) {
      setState(() => _error = 'Add at least one food to this meal.');
      return;
    }
    final items = <MealFoodItem>[];
    for (final selected in _selectedFoods) {
      final quantity = double.tryParse(selected.quantityText.trim());
      if (quantity == null || !quantity.isFinite || quantity <= 0) {
        setState(
          () => _error = 'Enter a valid positive quantity for each food.',
        );
        return;
      }
      final food = selected.food;
      items.add(
        MealFoodItem(
          foodId: food.id,
          foodName: food.name,
          servingSize: food.servingSize,
          servingUnit: food.servingUnit,
          caloriesPerServing: food.caloriesPerServing,
          proteinGramsPerServing: food.proteinGramsPerServing,
          carbsGramsPerServing: food.carbsGramsPerServing,
          fatGramsPerServing: food.fatGramsPerServing,
          quantity: quantity,
        ),
      );
    }
    final meal = Meal(
      name: _selectedCategory,
      category: _selectedCategory,
      consumedAt: DateUtils.dateOnly(widget.selectedDate),
      items: items,
    );
    try {
      await widget.mealRepository.save(meal);
      setState(() {
        _selectedFoods.clear();
        _error = null;
      });
      await _loadData();
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not save meal: $error');
    }
  }

  Future<void> _saveLegacyEntry() async {
    final name = _legacyNameController.text.trim();
    final calories = int.tryParse(_legacyCaloriesController.text.trim());
    final protein = double.tryParse(_legacyProteinController.text.trim());
    if (name.isEmpty ||
        calories == null ||
        calories < 0 ||
        protein == null ||
        !protein.isFinite ||
        protein < 0) {
      setState(
        () => _error = 'Enter a name and valid non-negative nutrition values.',
      );
      return;
    }
    try {
      await widget.repository.save(
        NutritionEntry(
          date: DateUtils.dateOnly(widget.selectedDate),
          name: name,
          calories: calories,
          proteinGrams: protein,
        ),
      );
      _legacyNameController.clear();
      _legacyCaloriesController.clear();
      _legacyProteinController.clear();
      setState(() => _error = null);
      await _loadData();
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not save nutrition entry: $error');
      }
    }
  }

  Future<void> _deleteLegacyEntry(NutritionEntry entry) async {
    try {
      await widget.repository.delete(entry.id);
      await _loadData();
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not delete nutrition entry: $error');
      }
    }
  }

  Future<void> _deleteMeal(Meal meal) async {
    try {
      await widget.mealRepository.delete(meal.id);
      await _loadData();
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not delete meal: $error');
    }
  }

  String _formatAmount(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final dailyEntries = _entriesForSelectedDate;
    final dailyMeals = _mealsForSelectedDate;
    final totals = _dailyTotals;

    return ListView(
      key: const ValueKey('nutrition-page-list'),
      padding: const EdgeInsets.all(12),
      children: [
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrition · ${DateFormat('d MMM yyyy').format(widget.selectedDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null && _entries.isEmpty && _meals.isEmpty)
                _loadError()
              else if (dailyEntries.isEmpty && dailyMeals.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('No nutrition entries logged for this day.'),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_formatAmount(totals.calories)} kcal · '
                    '${totals.proteinGrams.toStringAsFixed(1)} g protein',
                    key: const ValueKey('daily-nutrition-total'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
            ],
          ),
        ),
        _foodLibraryCard(),
        _mealBuilderCard(),
        _legacyEntryCard(),
        _historyCard(dailyMeals, dailyEntries),
      ],
    );
  }

  Widget _card(Widget child) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _loadError() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Nutrition data could not be loaded.'),
      TextButton(
        key: const ValueKey('retry-nutrition-load'),
        onPressed: _loadData,
        child: const Text('Try again'),
      ),
    ],
  );

  Widget _foodLibraryCard() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Food library',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              key: const ValueKey('create-food'),
              onPressed: _isLoading ? null : _createFood,
              icon: const Icon(Icons.add),
              label: const Text('Add food'),
            ),
          ],
        ),
        TextField(
          key: const ValueKey('food-search-field'),
          controller: _foodSearchController,
          onChanged: _searchFoods,
          decoration: const InputDecoration(
            labelText: 'Search foods',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_searchError != null)
          Text('Food search failed: $_searchError')
        else if (_searchResults.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _foodSearchController.text.trim().isEmpty
                  ? 'No foods yet. Add a food to start your library.'
                  : 'No foods match your search.',
              key: const ValueKey('food-search-empty'),
            ),
          )
        else
          ..._searchResults.map(
            (food) => ListTile(
              key: ValueKey('food-search-result-${food.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(food.name),
              subtitle: Text(
                '${_formatAmount(food.servingSize)} ${food.servingUnit} · '
                '${_formatAmount(food.caloriesPerServing)} kcal per serving',
              ),
              trailing: IconButton(
                tooltip: 'Add ${food.name} to meal',
                onPressed: () => _selectFood(food),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _mealBuilderCard() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add food or meal',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        DropdownButtonFormField<String>(
          key: const ValueKey('meal-category-field'),
          initialValue: _selectedCategory,
          decoration: const InputDecoration(labelText: 'Meal category'),
          items: _categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (category) {
            if (category != null) setState(() => _selectedCategory = category);
          },
        ),
        if (_selectedFoods.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Choose foods from the library above.'),
          )
        else
          ..._selectedFoods.asMap().entries.map((entry) {
            final index = entry.key;
            final selected = entry.value;
            return Row(
              key: ValueKey('selected-food-$index-${selected.food.id}'),
              children: [
                Expanded(child: Text(selected.food.name)),
                SizedBox(
                  width: 125,
                  child: TextFormField(
                    key: ValueKey('meal-quantity-$index-${selected.food.id}'),
                    initialValue: selected.quantityText,
                    onChanged: (value) => selected.quantityText = value,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Quantity (${selected.food.servingUnit})',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove ${selected.food.name}',
                  onPressed: () =>
                      setState(() => _selectedFoods.removeAt(index)),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ],
            );
          }),
        const SizedBox(height: 8),
        FilledButton(
          key: const ValueKey('save-meal'),
          onPressed: _isLoading ? null : _saveMeal,
          child: const Text('Save meal'),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, key: const ValueKey('nutrition-error')),
          ),
      ],
    ),
  );

  Widget _legacyEntryCard() => _card(
    ExpansionTile(
      key: const ValueKey('legacy-entry-expansion'),
      tilePadding: EdgeInsets.zero,
      title: const Text('Add legacy nutrition entry'),
      subtitle: const Text('For older entries with calories and protein only'),
      children: [
        TextField(
          key: const ValueKey('nutrition-name-field'),
          controller: _legacyNameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('nutrition-calories-field'),
                controller: _legacyCaloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: const ValueKey('nutrition-protein-field'),
                controller: _legacyProteinController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Protein (g)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey('save-nutrition-entry'),
          onPressed: _isLoading ? null : _saveLegacyEntry,
          child: const Text('Add legacy entry'),
        ),
      ],
    ),
  );

  Widget _historyCard(List<Meal> meals, List<NutritionEntry> entries) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition history',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null && meals.isEmpty && entries.isEmpty)
          _loadError()
        else if (meals.isEmpty && entries.isEmpty)
          const Text('Your meals and older entries will appear here.')
        else ...[
          if (meals.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Meals'),
            ),
            ...meals.map(_mealTile),
          ],
          if (entries.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Legacy entries'),
            ),
            ...entries.map(_legacyTile),
          ],
        ],
      ],
    ),
  );

  Widget _mealTile(Meal meal) => ListTile(
    key: ValueKey('meal-entry-${meal.id}'),
    contentPadding: EdgeInsets.zero,
    title: Text(meal.category ?? meal.name),
    subtitle: Text(
      '${meal.items.map((item) => '${item.foodName} · '
          '${_formatAmount(item.quantity)} ${item.servingUnit}').join(', ')}\n'
      '${_formatAmount(meal.totalCalories)} kcal · '
      '${meal.totalProteinGrams.toStringAsFixed(1)} g protein · '
      '${meal.totalCarbsGrams.toStringAsFixed(1)} g carbs · '
      '${meal.totalFatGrams.toStringAsFixed(1)} g fats',
    ),
    isThreeLine: true,
    trailing: IconButton(
      tooltip: 'Delete meal',
      onPressed: () => _deleteMeal(meal),
      icon: const Icon(Icons.delete_outline),
    ),
  );

  Widget _legacyTile(NutritionEntry entry) => ListTile(
    key: ValueKey('nutrition-entry-${entry.id}'),
    contentPadding: EdgeInsets.zero,
    title: Text(entry.name),
    subtitle: Text('${entry.calories} kcal · ${entry.proteinGrams} g protein'),
    trailing: IconButton(
      tooltip: 'Delete legacy entry',
      onPressed: () => _deleteLegacyEntry(entry),
      icon: const Icon(Icons.delete_outline),
    ),
  );
}

class _SelectedFood {
  _SelectedFood({required this.food, required this.quantityText});

  final Food food;
  String quantityText;
}
