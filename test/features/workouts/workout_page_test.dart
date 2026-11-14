import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/exercise_library_item.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/features/workouts/workout_page.dart';

import '../../support/fake_workout_repository.dart';
import '../../support/fake_exercise_library_repository.dart';

void main() {
  late FakeWorkoutRepository repository;
  late FakeExerciseLibraryRepository libraryRepository;

  setUp(() async {
    repository = FakeWorkoutRepository();
    libraryRepository = FakeExerciseLibraryRepository();
  });

  Future<void> pumpWorkoutPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutPage(
            repository: repository,
            exerciseLibraryRepository: libraryRepository,
            selectedDate: DateTime(2026, 11, 14),
            onWorkoutsChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('creates a dated workout, saves it, reloads it, and edits it', (
    tester,
  ) async {
    await pumpWorkoutPage(tester);

    await tester.tap(find.byKey(const ValueKey('start-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('choose-workout-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('16').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-exercise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-custom-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('exercise-name-input')),
      'Squat',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-add-exercise')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-set-0')));
    await tester.pumpAndSettle();
    final weightField = find.byKey(const ValueKey('set-weight-0-0'));
    final repsField = find.byKey(const ValueKey('set-reps-0-0'));
    await tester.enterText(weightField, '45');
    await tester.enterText(repsField, '8');

    final saveButton = find.byKey(const ValueKey('save-workout'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Mon, 16 Nov 2026'), findsOneWidget);
    expect(find.text('1 exercise · 1 set'), findsOneWidget);
    final savedWorkouts = await repository.getAll();
    expect(savedWorkouts, hasLength(1));
    final savedId = savedWorkouts.single.id;

    // Recreate the page to check that the workout is restored from Isar.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await pumpWorkoutPage(tester);
    expect(find.byKey(ValueKey('workout-$savedId')), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('workout-$savedId')));
    await tester.pumpAndSettle();
    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('edit-workout')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('set-weight-0-0')), '50');
    final saveChanges = find.byKey(const ValueKey('save-workout-changes'));
    await tester.ensureVisible(saveChanges);
    await tester.tap(saveChanges);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final unchangedWorkout = await repository.getById(savedId);
    expect(unchangedWorkout!.exercises.single.sets.single.weight, 45);

    await tester.tap(saveChanges);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('confirm-save-workout-changes')),
    );
    await tester.pumpAndSettle();

    final updatedWorkout = await repository.getById(savedId);
    expect(updatedWorkout!.exercises.single.sets.single.weight, 50);
  });

  testWidgets('deletes a set and removes an exercise before saving edits', (
    tester,
  ) async {
    final id = await repository.save(
      Workout(
        date: DateTime(2026, 11, 14),
        exercises: [
          Exercise(
            name: 'Squat',
            sets: [
              WorkoutSet(weight: 40, reps: 10, setNumber: 1),
              WorkoutSet(weight: 45, reps: 8, setNumber: 2),
            ],
          ),
          Exercise(
            name: 'Press',
            sets: [WorkoutSet(weight: 20, reps: 10, setNumber: 1)],
          ),
        ],
      ),
    );

    await pumpWorkoutPage(tester);
    await tester.tap(find.byKey(ValueKey('workout-$id')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    final editButton = find.byKey(const ValueKey('edit-workout'));
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    final deleteSetButton = find.byKey(const ValueKey('remove-set-0-1'));
    await tester.ensureVisible(deleteSetButton);
    await tester.tap(deleteSetButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-removal')));
    await tester.pumpAndSettle();

    final removeExerciseButton = find.byKey(
      const ValueKey('remove-exercise-1'),
    );
    await tester.ensureVisible(removeExerciseButton);
    await tester.tap(removeExerciseButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-removal')));
    await tester.pumpAndSettle();

    final saveChanges = find.byKey(const ValueKey('save-workout-changes'));
    await tester.ensureVisible(saveChanges);
    await tester.tap(saveChanges);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('confirm-save-workout-changes')),
    );
    await tester.pumpAndSettle();

    final savedWorkout = await repository.getById(id);
    expect(savedWorkout!.exercises, hasLength(1));
    expect(savedWorkout.exercises.single.name, 'Squat');
    expect(savedWorkout.exercises.single.sets, hasLength(1));
    expect(savedWorkout.exercises.single.sets.single.setNumber, 1);
  });

  testWidgets('searches and selects a library exercise with its ID snapshot', (
    tester,
  ) async {
    final libraryId = await libraryRepository.save(
      ExerciseLibraryItem(
        name: 'Dumbbell Row',
        muscleGroup: 'Back',
        equipment: 'Dumbbell',
      ),
    );
    await pumpWorkoutPage(tester);
    await tester.tap(find.byKey(const ValueKey('start-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('exercise-library-search')),
      'row',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dumbbell Row'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-set-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('set-reps-0-0')), '10');
    final save = find.byKey(const ValueKey('save-workout'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    final saved = (await repository.getAll()).single.exercises.single;
    expect(saved.libraryExerciseId, libraryId);
    expect(saved.name, 'Dumbbell Row');
  });

  testWidgets('shows previous sets separately from the current workout sets', (
    tester,
  ) async {
    final previousId = await repository.save(
      Workout(
        date: DateTime(2026, 11, 13),
        exercises: [
          Exercise(
            name: 'Bench   Press',
            sets: [
              WorkoutSet(weight: 40, reps: 10, setNumber: 1),
              WorkoutSet(weight: 45, reps: 8, setNumber: 2),
            ],
          ),
        ],
      ),
    );
    await pumpWorkoutPage(tester);
    await tester.tap(find.byKey(const ValueKey('start-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-exercise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-custom-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('exercise-name-input')),
      'bench press',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-add-exercise')));
    await tester.pumpAndSettle();

    expect(find.text('Previous session'), findsOneWidget);
    expect(find.text('Set 1: 40 kg × 10 reps'), findsOneWidget);
    expect(find.text('Set 2: 45 kg × 8 reps'), findsOneWidget);
    expect(find.byKey(const ValueKey('set-weight-0-0')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('add-set-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('set-weight-0-0')), '50');

    final savedPreviousWorkout = await repository.getById(previousId);
    expect(savedPreviousWorkout!.exercises.single.sets.first.weight, 40);
    expect(savedPreviousWorkout.exercises.single.sets.last.weight, 45);
  });

  testWidgets('editing an older workout shows only earlier performance', (
    tester,
  ) async {
    await repository.save(
      Workout(
        date: DateTime(2026, 11, 9),
        exercises: [
          Exercise(name: 'Squat', sets: [WorkoutSet(weight: 60, reps: 5)]),
        ],
      ),
    );
    final olderId = await repository.save(
      Workout(
        date: DateTime(2026, 11, 12),
        exercises: [
          Exercise(name: 'Squat', sets: [WorkoutSet(weight: 70, reps: 5)]),
        ],
      ),
    );
    await repository.save(
      Workout(
        date: DateTime(2026, 11, 13),
        exercises: [
          Exercise(name: 'Squat', sets: [WorkoutSet(weight: 90, reps: 1)]),
        ],
      ),
    );

    await pumpWorkoutPage(tester);
    await tester.tap(find.byKey(ValueKey('workout-$olderId')));
    await tester.pumpAndSettle();

    expect(find.text('Set 1: 60 kg × 5 reps'), findsOneWidget);
    expect(find.text('Set 1: 90 kg × 1 reps'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('edit-workout')));
    await tester.pumpAndSettle();
    expect(find.text('Set 1: 60 kg × 5 reps'), findsOneWidget);
    expect(find.text('Set 1: 90 kg × 1 reps'), findsNothing);
  });

  testWidgets('custom exercises can optionally be saved to the library', (
    tester,
  ) async {
    await pumpWorkoutPage(tester);
    await tester.tap(find.byKey(const ValueKey('start-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-exercise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-custom-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('exercise-name-input')),
      'Band Pull Apart',
    );
    await tester.tap(find.text('Save to exercise library'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-add-exercise')));
    await tester.pumpAndSettle();

    expect(find.text('Band Pull Apart'), findsOneWidget);
    expect(find.text('No previous sets recorded.'), findsOneWidget);
    expect(libraryRepository.items.single.name, 'Band Pull Apart');
    expect(libraryRepository.items.single.muscleGroup, 'Other');
  });

  testWidgets('opens personal records from workout history', (tester) async {
    await repository.save(
      Workout(
        date: DateTime(2026, 11, 13),
        exercises: [
          Exercise(
            name: 'Shoulder Press',
            sets: [WorkoutSet(weight: 25, reps: 8)],
          ),
        ],
      ),
    );
    await pumpWorkoutPage(tester);

    await tester.tap(find.byKey(const ValueKey('open-personal-records')));
    await tester.pumpAndSettle();

    expect(find.text('Personal Records'), findsOneWidget);
    expect(find.text('Shoulder Press'), findsOneWidget);
    expect(find.text('25 kg × 8 reps'), findsOneWidget);
  });

  testWidgets('shows live PRs only when a new set beats saved records', (
    tester,
  ) async {
    await repository.save(
      Workout(
        date: DateTime(2026, 11, 13),
        exercises: [
          Exercise(
            name: 'Bench Press',
            sets: [WorkoutSet(weight: 100, reps: 5)],
          ),
        ],
      ),
    );
    await pumpWorkoutPage(tester);
    await tester.tap(find.byKey(const ValueKey('start-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-exercise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-custom-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('exercise-name-input')),
      'bench press',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-add-exercise')));
    await tester.pumpAndSettle();

    expect(find.textContaining('New PR'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('add-set-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('set-weight-0-0')), '105');
    await tester.pump();
    await tester.enterText(find.byKey(const ValueKey('set-reps-0-0')), '4');
    await tester.pump();

    expect(find.text('New PR · Heaviest set: 105 kg × 4 reps'), findsOneWidget);
    expect(find.textContaining('Most reps'), findsNothing);
  });

  testWidgets('zero-weight sets can create reps PRs with weight context', (
    tester,
  ) async {
    await repository.save(
      Workout(
        date: DateTime(2026, 11, 13),
        exercises: [
          Exercise(name: 'Sit Up', sets: [WorkoutSet(weight: 0, reps: 12)]),
        ],
      ),
    );
    await pumpWorkoutPage(tester);
    await tester.tap(find.byKey(const ValueKey('start-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-exercise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-custom-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('exercise-name-input')),
      'Sit Up',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-add-exercise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-set-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('set-reps-0-0')), '13');
    await tester.pump();

    expect(find.text('New PR · Most reps: 13 reps at 0 kg'), findsOneWidget);
  });

  testWidgets(
    'viewing shows no new PR and edit baseline excludes that workout',
    (tester) async {
      await repository.save(
        Workout(
          date: DateTime(2026, 11, 10),
          exercises: [
            Exercise(name: 'Deadlift', sets: [WorkoutSet(weight: 80, reps: 5)]),
          ],
        ),
      );
      final recordWorkoutId = await repository.save(
        Workout(
          date: DateTime(2026, 11, 12),
          exercises: [
            Exercise(
              name: 'Deadlift',
              sets: [WorkoutSet(weight: 100, reps: 3)],
            ),
          ],
        ),
      );
      await pumpWorkoutPage(tester);
      await tester.tap(find.byKey(ValueKey('workout-$recordWorkoutId')));
      await tester.pumpAndSettle();

      expect(find.textContaining('New PR'), findsNothing);
      final editButton = find.byKey(const ValueKey('edit-workout'));
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.textContaining('New PR'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('set-weight-0-0')),
        '90',
      );
      await tester.pump();

      // 90 kg is a PR over the other saved workout's 80 kg. It would not be
      // detected if the workout being edited remained in the baseline (100 kg).
      expect(
        find.text('New PR · Heaviest set: 90 kg × 3 reps'),
        findsOneWidget,
      );
    },
  );
}
