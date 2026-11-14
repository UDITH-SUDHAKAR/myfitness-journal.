import 'dart:io';
import 'dart:ffi' show Abi;

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/exercise_library_item.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/core/storage/isar_workout_repository.dart';
import 'package:myfitness_journal/core/storage/isar_exercise_library_repository.dart';

void main() {
  late Directory temporaryDirectory;
  late Isar isar;
  late IsarWorkoutRepository repository;

  setUpAll(() async {
    // Flutter widget tests need Isar's native core initialized explicitly.
    // Store the downloaded test binary in the system temp directory instead
    // of leaving a platform DLL in the project root.
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
    temporaryDirectory = await Directory.systemTemp.createTemp('workout_test_');
    isar = await Isar.open([
      WorkoutSchema,
      ExerciseLibraryItemSchema,
    ], directory: temporaryDirectory.path);
    repository = IsarWorkoutRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await temporaryDirectory.delete(recursive: true);
  });

  test('saves and retrieves workouts with nested exercises and sets', () async {
    final libraryRepository = IsarExerciseLibraryRepository(isar);
    final libraryId = await libraryRepository.save(
      ExerciseLibraryItem(
        name: 'Squat',
        muscleGroup: 'Legs',
        equipment: 'Barbell',
      ),
    );
    final workout = Workout(
      date: DateTime(2026, 11, 14),
      exercises: [
        Exercise(
          name: 'Squat',
          libraryExerciseId: libraryId,
          sets: [
            WorkoutSet(weight: 60, reps: 8, setNumber: 1),
            WorkoutSet(weight: 65, reps: 6, setNumber: 2),
          ],
        ),
      ],
    );

    final id = await repository.save(workout);
    final savedWorkout = await repository.getById(id);
    final allWorkouts = await repository.getAll();

    expect(id, greaterThan(0));
    expect(savedWorkout, isNotNull);
    expect(savedWorkout!.date, DateTime(2026, 11, 14));
    expect(savedWorkout.exercises, hasLength(1));
    expect(savedWorkout.exercises.single.name, 'Squat');
    expect(savedWorkout.exercises.single.libraryExerciseId, libraryId);
    expect(savedWorkout.exercises.single.sets, hasLength(2));
    expect(savedWorkout.exercises.single.sets.last.weight, 65);
    expect(savedWorkout.exercises.single.sets.last.reps, 6);
    expect(savedWorkout.exercises.single.sets.last.setNumber, 2);
    expect(allWorkouts, hasLength(1));
  });

  test('exercise library supports name search, update, and delete', () async {
    final library = IsarExerciseLibraryRepository(isar);
    final id = await library.save(
      ExerciseLibraryItem(
        name: 'Incline Dumbbell Press',
        muscleGroup: 'Chest',
        equipment: 'Dumbbell',
        description: 'Press while seated on an incline bench.',
      ),
    );
    await library.save(
      ExerciseLibraryItem(
        name: 'Back Squat',
        muscleGroup: 'Legs',
        equipment: 'Barbell',
      ),
    );

    expect(await library.search('dumbbell'), hasLength(1));
    expect((await library.search('')).length, 2);

    final item = (await library.search('Incline')).single;
    item.name = 'Incline Press';
    expect(await library.update(item), isTrue);
    expect((await library.search('Incline')).single.name, 'Incline Press');
    expect(await library.delete(id), isTrue);
    expect(await library.search('Incline'), isEmpty);
  });

  test(
    'library deletion leaves logged exercise name snapshot intact',
    () async {
      final library = IsarExerciseLibraryRepository(isar);
      final libraryId = await library.save(
        ExerciseLibraryItem(
          name: 'Cable Fly',
          muscleGroup: 'Chest',
          equipment: 'Cable',
        ),
      );
      final workoutId = await repository.save(
        Workout(
          date: DateTime(2026, 11, 14),
          exercises: [
            Exercise(name: 'Cable Fly', libraryExerciseId: libraryId),
          ],
        ),
      );

      expect(await library.delete(libraryId), isTrue);
      final loggedExercise = (await repository.getById(
        workoutId,
      ))!.exercises.single;
      expect(loggedExercise.name, 'Cable Fly');
      expect(loggedExercise.libraryExerciseId, libraryId);
    },
  );

  test('updates an existing workout and reports a missing workout', () async {
    final id = await repository.save(Workout(date: DateTime(2026, 11, 14)));
    final updatedWorkout = Workout(
      id: id,
      date: DateTime(2026, 11, 15),
      exercises: [Exercise(name: 'Deadlift')],
    );
    final missingWorkout = Workout(id: id + 100, date: DateTime(2026, 11, 15));

    expect(await repository.update(updatedWorkout), isTrue);
    expect(await repository.update(missingWorkout), isFalse);

    final savedWorkout = await repository.getById(id);
    expect(savedWorkout!.date, DateTime(2026, 11, 15));
    expect(savedWorkout.exercises.single.name, 'Deadlift');
  });

  test('deletes an existing workout and reports a missing workout', () async {
    final id = await repository.save(Workout(date: DateTime(2026, 11, 14)));

    expect(await repository.delete(id), isTrue);
    expect(await repository.delete(id), isFalse);
    expect(await repository.getById(id), isNull);
    expect(await repository.getAll(), isEmpty);
  });
}
