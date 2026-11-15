import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/food.dart';
import 'package:myfitness_journal/core/models/meal.dart';
import 'package:myfitness_journal/core/models/nutrition_entry.dart';
import 'package:myfitness_journal/features/nutrition/nutrition_page.dart';

import '../../support/fake_food_repository.dart';
import '../../support/fake_meal_repository.dart';
import '../../support/fake_nutrition_repository.dart';

Food oats({int id = 1}) => Food(
  id: id,
  name: 'Oats',
  servingSize: 100,
  servingUnit: 'g',
  caloriesPerServing: 200,
  proteinGramsPerServing: 20,
  carbsGramsPerServing: 30,
  fatGramsPerServing: 10,
);

Widget buildPage({
  FakeNutritionRepository? legacyRepository,
  FakeFoodRepository? foodRepository,
  FakeMealRepository? mealRepository,
  DateTime? selectedDate,
}) => MaterialApp(
  home: Scaffold(
    body: NutritionPage(
      repository: legacyRepository ?? FakeNutritionRepository(),
      foodRepository: foodRepository ?? FakeFoodRepository(),
      mealRepository: mealRepository ?? FakeMealRepository(),
      selectedDate: selectedDate ?? DateTime(2026, 11, 14),
      onEntriesChanged: (_) {},
      onMealsChanged: (_) {},
      onLoadFinished: (_) {},
    ),
  ),
);

void main() {
  testWidgets('shows existing empty state and preserves legacy entry logging', (
    tester,
  ) async {
    final legacyRepository = FakeNutritionRepository();
    await tester.pumpWidget(buildPage(legacyRepository: legacyRepository));
    await tester.pumpAndSettle();

    expect(
      find.text('No nutrition entries logged for this day.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('legacy-entry-expansion')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('nutrition-name-field')),
      'Breakfast',
    );
    await tester.enterText(
      find.byKey(const ValueKey('nutrition-calories-field')),
      '400',
    );
    await tester.enterText(
      find.byKey(const ValueKey('nutrition-protein-field')),
      '22.5',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('save-nutrition-entry')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-nutrition-entry')));
    await tester.pumpAndSettle();

    expect(find.text('400 kcal · 22.5 g protein'), findsOneWidget);
    expect(find.text('Legacy entries'), findsOneWidget);
    expect(await legacyRepository.getAll(), hasLength(1));
  });

  testWidgets('searches foods and logs a categorized fractional meal', (
    tester,
  ) async {
    final foodRepository = FakeFoodRepository(
      foods: [oats(), oats(id: 2)..name = 'Oat milk'],
    );
    final mealRepository = FakeMealRepository();
    await tester.pumpWidget(
      buildPage(foodRepository: foodRepository, mealRepository: mealRepository),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'OAT MILK',
    );
    await tester.pumpAndSettle();
    expect(find.text('Oat milk'), findsOneWidget);
    expect(find.text('Oats'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'oats',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Oats to meal'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('meal-category-field')),
    );
    await tester.tap(find.byKey(const ValueKey('meal-category-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dinner').last);
    await tester.pumpAndSettle();

    final quantity = find.byKey(const ValueKey('meal-quantity-0-1'));
    await tester.ensureVisible(quantity);
    await tester.enterText(quantity, '150.5');
    await tester.ensureVisible(find.byKey(const ValueKey('save-meal')));
    await tester.tap(find.byKey(const ValueKey('save-meal')));
    await tester.pumpAndSettle();

    final saved = (await mealRepository.getAll()).single;
    expect(saved.category, 'Dinner');
    expect(saved.items.single.quantity, 150.5);
    expect(saved.totalCalories, 301);
    expect(saved.totalProteinGrams, closeTo(30.1, 0.000001));
    expect(saved.totalCarbsGrams, closeTo(45.15, 0.000001));
    expect(saved.totalFatGrams, closeTo(15.05, 0.000001));
    expect(find.byKey(const ValueKey('meal-entry-1')), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('nutrition-page-list')),
      const Offset(0, 1400),
    );
    await tester.pumpAndSettle();
    expect(find.text('301 kcal · 30.1 g protein'), findsOneWidget);
  });

  testWidgets('creates a reusable Food through the library dialog', (
    tester,
  ) async {
    final foods = FakeFoodRepository();
    await tester.pumpWidget(buildPage(foodRepository: foods));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('create-food')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('food-name-field')),
      'Rice',
    );
    await tester.enterText(
      find.byKey(const ValueKey('food-calories-field')),
      '130',
    );
    await tester.enterText(
      find.byKey(const ValueKey('food-protein-field')),
      '2.7',
    );
    await tester.enterText(
      find.byKey(const ValueKey('food-carbs-field')),
      '28',
    );
    await tester.enterText(
      find.byKey(const ValueKey('food-fats-field')),
      '0.3',
    );
    await tester.tap(find.byKey(const ValueKey('save-food-definition')));
    await tester.pumpAndSettle();

    expect((await foods.getAll()).single.name, 'Rice');
    expect(find.byKey(const ValueKey('food-search-result-1')), findsOneWidget);
  });

  testWidgets('history filters Meals and legacy entries by selected date', (
    tester,
  ) async {
    final meals = FakeMealRepository(
      meals: [
        Meal(
          id: 1,
          name: 'Breakfast',
          category: 'Breakfast',
          consumedAt: DateTime(2026, 11, 14, 8),
          items: [
            MealFoodItem(
              foodName: 'Oats',
              servingSize: 100,
              servingUnit: 'g',
              caloriesPerServing: 200,
              proteinGramsPerServing: 20,
              carbsGramsPerServing: 30,
              fatGramsPerServing: 10,
              quantity: 100,
            ),
          ],
        ),
        Meal(
          id: 2,
          name: 'Dinner',
          category: 'Dinner',
          consumedAt: DateTime(2026, 11, 13),
          items: [
            MealFoodItem(
              foodName: 'Oats',
              servingSize: 100,
              servingUnit: 'g',
              caloriesPerServing: 200,
              proteinGramsPerServing: 20,
              carbsGramsPerServing: 30,
              fatGramsPerServing: 10,
              quantity: 100,
            ),
          ],
        ),
      ],
    );
    final legacy = FakeNutritionRepository();
    await legacy.save(
      NutritionEntry(
        date: DateTime(2026, 11, 14, 18),
        name: 'Old snack',
        calories: 100,
        proteinGrams: 5,
      ),
    );
    await legacy.save(
      NutritionEntry(
        date: DateTime(2026, 11, 13),
        name: 'Yesterday',
        calories: 500,
        proteinGrams: 15,
      ),
    );

    await tester.pumpWidget(
      buildPage(
        legacyRepository: legacy,
        mealRepository: meals,
        selectedDate: DateTime(2026, 11, 14),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('meal-entry-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('meal-entry-2')), findsNothing);
    expect(find.text('Old snack'), findsOneWidget);
    expect(find.text('Yesterday'), findsNothing);
    expect(find.text('300 kcal · 25.0 g protein'), findsOneWidget);
  });

  testWidgets('shows loading and repository error states', (tester) async {
    await tester.pumpWidget(
      buildPage(foodRepository: FakeFoodRepository(failLoading: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Nutrition data could not be loaded.'), findsWidgets);
    expect(find.byKey(const ValueKey('retry-nutrition-load')), findsOneWidget);
  });
}
