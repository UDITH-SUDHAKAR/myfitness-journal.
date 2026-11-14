import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/core/models/exercise_library_item.dart';
import 'package:myfitness_journal/core/models/food.dart';
import 'package:myfitness_journal/core/models/meal.dart';
import 'package:myfitness_journal/core/models/nutrition_entry.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/storage/food_repository.dart';
import 'package:myfitness_journal/core/storage/isar_food_repository.dart';
import 'package:myfitness_journal/core/storage/isar_meal_repository.dart';
import 'package:myfitness_journal/core/storage/isar_nutrition_repository.dart';
import 'package:myfitness_journal/core/storage/meal_repository.dart';

void main() {
  late Directory temporaryDirectory;
  late Isar isar;
  late FoodRepository foodRepository;
  late MealRepository mealRepository;

  setUpAll(() async {
    final extension = Platform.isWindows
        ? 'dll'
        : Platform.isMacOS
        ? 'dylib'
        : 'so';
    final prefix = Platform.isWindows ? '' : 'lib';
    final libraryPath =
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        '${prefix}isar_community_3_4_1.$extension';
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): libraryPath},
      download: true,
    );
  });

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('nutrition_');
    isar = await Isar.open([
      WorkoutSchema,
      ExerciseLibraryItemSchema,
      BodyWeightEntrySchema,
      NutritionEntrySchema,
      FoodSchema,
      MealSchema,
    ], directory: temporaryDirectory.path);
    foodRepository = IsarFoodRepository(isar);
    mealRepository = IsarMealRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await temporaryDirectory.delete(recursive: true);
  });

  test('Food repository supports create, read, update, and delete', () async {
    final food = makeFood();
    final id = await foodRepository.save(food);

    expect(food.id, id);
    expect((await foodRepository.getById(id))?.name, 'Oats');
    expect((await foodRepository.getAll()).single.servingUnit, 'g');

    food.name = 'Rolled oats';
    expect(await foodRepository.update(food), isTrue);
    expect((await foodRepository.getById(id))?.name, 'Rolled oats');
    expect(await foodRepository.delete(id), isTrue);
    expect(await foodRepository.getById(id), isNull);
    expect(await foodRepository.delete(id), isFalse);
    expect(await foodRepository.update(food), isFalse);
  });

  test('Meal repository round-trips embedded snapshots and CRUD', () async {
    final id = await mealRepository.save(makeMeal());
    final meal = await mealRepository.getById(id);

    expect(meal?.consumedAt, DateTime(2026, 11, 14, 8, 30));
    expect(meal?.items, hasLength(2));
    expect(meal?.items.first.foodId, 17);
    expect(meal?.items.first.foodName, 'Oats');
    expect(meal?.totalCalories, 350);
    expect(meal?.totalProteinGrams, 33);
    expect(meal?.totalCarbsGrams, 50);
    expect(meal?.totalFatGrams, 17);
    expect((await mealRepository.getAll()).single.id, id);

    meal!.name = 'Edited breakfast';
    expect(await mealRepository.update(meal), isTrue);
    expect((await mealRepository.getById(id))?.name, 'Edited breakfast');
    expect(await mealRepository.delete(id), isTrue);
    expect(await mealRepository.getById(id), isNull);
    expect(await mealRepository.delete(id), isFalse);
    expect(await mealRepository.update(meal), isFalse);
  });

  test('repository rejects invalid Food and Meal values', () async {
    expect(
      () => foodRepository.save(makeFood(servingSize: double.nan)),
      throwsArgumentError,
    );
    expect(
      () => mealRepository.save(
        Meal(name: 'Empty', consumedAt: DateTime(2026), items: const []),
      ),
      throwsArgumentError,
    );
  });

  test(
    'meal snapshots remain unchanged after source Food edits or deletion',
    () async {
      final food = makeFood();
      final foodId = await foodRepository.save(food);
      final mealId = await mealRepository.save(
        Meal(
          name: 'Snack',
          consumedAt: DateTime(2026, 11, 14),
          items: [
            MealFoodItem(
              foodId: foodId,
              foodName: food.name,
              servingSize: food.servingSize,
              servingUnit: food.servingUnit,
              caloriesPerServing: food.caloriesPerServing,
              proteinGramsPerServing: food.proteinGramsPerServing,
              carbsGramsPerServing: food.carbsGramsPerServing,
              fatGramsPerServing: food.fatGramsPerServing,
              quantity: 50,
            ),
          ],
        ),
      );

      food.name = 'Changed food';
      food.caloriesPerServing = 900;
      expect(await foodRepository.update(food), isTrue);
      expect(await foodRepository.delete(foodId), isTrue);

      final savedMeal = (await mealRepository.getById(mealId))!;
      expect(savedMeal.items.single.foodName, 'Oats');
      expect(savedMeal.items.single.caloriesPerServing, 200);
      expect(savedMeal.totalCalories, 100);
    },
  );

  test(
    'NutritionEntry records remain readable with new schemas registered',
    () async {
      await isar.close(deleteFromDisk: true);
      isar = await Isar.open([
        NutritionEntrySchema,
      ], directory: temporaryDirectory.path);
      final legacyId = await isar.writeTxn(
        () => isar.nutritionEntrys.put(
          NutritionEntry(
            date: DateTime(2026, 11, 13),
            name: 'Legacy lunch',
            calories: 540,
            proteinGrams: 28.5,
          ),
        ),
      );
      await isar.close();
      isar = await Isar.open([
        WorkoutSchema,
        ExerciseLibraryItemSchema,
        BodyWeightEntrySchema,
        NutritionEntrySchema,
        FoodSchema,
        MealSchema,
      ], directory: temporaryDirectory.path);

      final entries = await IsarNutritionRepository(isar).getAll();
      expect(entries, hasLength(1));
      expect(entries.single.id, legacyId);
      expect(entries.single.name, 'Legacy lunch');
      expect(entries.single.calories, 540);
      expect(entries.single.proteinGrams, 28.5);
    },
  );
}

Food makeFood({double servingSize = 100}) => Food(
  name: 'Oats',
  servingSize: servingSize,
  servingUnit: 'g',
  caloriesPerServing: 200,
  proteinGramsPerServing: 20,
  carbsGramsPerServing: 30,
  fatGramsPerServing: 10,
);

Meal makeMeal() => Meal(
  name: 'Breakfast',
  consumedAt: DateTime(2026, 11, 14, 8, 30),
  items: [
    MealFoodItem(
      foodId: 17,
      foodName: 'Oats',
      servingSize: 100,
      servingUnit: 'g',
      caloriesPerServing: 200,
      proteinGramsPerServing: 20,
      carbsGramsPerServing: 30,
      fatGramsPerServing: 10,
      quantity: 150,
    ),
    MealFoodItem(
      foodId: 18,
      foodName: 'Milk',
      servingSize: 200,
      servingUnit: 'ml',
      caloriesPerServing: 100,
      proteinGramsPerServing: 6,
      carbsGramsPerServing: 10,
      fatGramsPerServing: 4,
      quantity: 100,
    ),
  ],
);
