import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/core/models/exercise_library_item.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/nutrition_entry.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/core/storage/isar_body_weight_repository.dart';
import 'package:myfitness_journal/core/storage/isar_nutrition_repository.dart';

void main() {
  late Directory temporaryDirectory;
  late Isar isar;
  late IsarBodyWeightRepository bodyWeightRepository;
  late IsarNutritionRepository nutritionRepository;

  setUpAll(() async {
    final libraryExtension = Platform.isWindows
        ? 'dll'
        : Platform.isMacOS
        ? 'dylib'
        : 'so';
    final libraryPrefix = Platform.isWindows ? '' : 'lib';
    final libraryPath =
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        '${libraryPrefix}isar_community_3_4_1.$libraryExtension';
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): libraryPath},
      download: true,
    );
  });

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('health_data_');
    isar = await Isar.open([
      WorkoutSchema,
      ExerciseLibraryItemSchema,
      BodyWeightEntrySchema,
      NutritionEntrySchema,
    ], directory: temporaryDirectory.path);
    bodyWeightRepository = IsarBodyWeightRepository(isar);
    nutritionRepository = IsarNutritionRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'body weight saves once per date, selects latest, updates, and deletes',
    () async {
      final firstId = await bodyWeightRepository.save(
        BodyWeightEntry(date: DateTime(2026, 11, 12, 8), weightKg: 71.2),
      );
      final sameDayId = await bodyWeightRepository.save(
        BodyWeightEntry(date: DateTime(2026, 11, 12, 21), weightKg: 71.5),
      );
      await bodyWeightRepository.save(
        BodyWeightEntry(date: DateTime(2026, 11, 14), weightKg: 72),
      );

      final entries = await bodyWeightRepository.getAll();
      expect(sameDayId, firstId);
      expect(entries, hasLength(2));
      expect(entries.first.date, DateTime(2026, 11, 14));
      expect(entries.last.weightKg, 71.5);

      final edited = BodyWeightEntry(
        id: entries.first.id,
        date: entries.first.date,
        weightKg: 72.4,
      );
      expect(await bodyWeightRepository.update(edited), isTrue);
      expect((await bodyWeightRepository.getAll()).first.weightKg, 72.4);
      expect(await bodyWeightRepository.delete(entries.first.id), isTrue);
      expect(await bodyWeightRepository.delete(entries.first.id), isFalse);
      expect((await bodyWeightRepository.getAll()).single.weightKg, 71.5);
    },
  );

  test(
    'nutrition entries persist, update, delete, and retain multiple meals',
    () async {
      final breakfastId = await nutritionRepository.save(
        NutritionEntry(
          date: DateTime(2026, 11, 14, 8),
          name: 'Breakfast',
          calories: 400,
          proteinGrams: 22.5,
        ),
      );
      await nutritionRepository.save(
        NutritionEntry(
          date: DateTime(2026, 11, 14, 19),
          name: 'Dinner',
          calories: 700,
          proteinGrams: 31,
        ),
      );

      var entries = await nutritionRepository.getAll();
      expect(entries, hasLength(2));
      expect(
        entries.map((entry) => entry.calories).reduce((a, b) => a + b),
        1100,
      );

      expect(
        await nutritionRepository.update(
          NutritionEntry(
            id: breakfastId,
            date: DateTime(2026, 11, 14, 8),
            name: 'Breakfast edited',
            calories: 450,
            proteinGrams: 24,
          ),
        ),
        isTrue,
      );
      entries = await nutritionRepository.getAll();
      expect(entries.last.name, 'Breakfast edited');
      expect(await nutritionRepository.delete(breakfastId), isTrue);
      expect((await nutritionRepository.getAll()).single.name, 'Dinner');
    },
  );

  test('empty health collections return empty lists', () async {
    expect(await bodyWeightRepository.getAll(), isEmpty);
    expect(await nutritionRepository.getAll(), isEmpty);
  });

  test(
    'adding health collections preserves existing workout records',
    () async {
      await isar.close();
      isar = await Isar.open([
        WorkoutSchema,
        ExerciseLibraryItemSchema,
      ], directory: temporaryDirectory.path);
      final savedId = await isar.writeTxn(
        () => isar.workouts.put(
          Workout(
            date: DateTime(2026, 11, 14),
            exercises: [
              Exercise(name: 'Squat', sets: [WorkoutSet(weight: 60, reps: 5)]),
            ],
          ),
        ),
      );
      await isar.close();

      isar = await Isar.open([
        WorkoutSchema,
        ExerciseLibraryItemSchema,
        BodyWeightEntrySchema,
        NutritionEntrySchema,
      ], directory: temporaryDirectory.path);

      final savedWorkout = await isar.workouts.get(savedId);
      expect(savedWorkout?.exercises.single.name, 'Squat');
      expect(savedWorkout?.exercises.single.sets.single.reps, 5);
    },
  );
}
