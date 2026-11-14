import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/features/workouts/workout_page.dart';

import '../../support/fake_workout_repository.dart';

void main() {
  late FakeWorkoutRepository repository;

  setUp(() async {
    repository = FakeWorkoutRepository();
  });

  Future<void> pumpWorkoutPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutPage(
            repository: repository,
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
    expect(find.text('1 exercise'), findsOneWidget);
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
    await tester.tap(find.byKey(const ValueKey('edit-workout')));
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
}
