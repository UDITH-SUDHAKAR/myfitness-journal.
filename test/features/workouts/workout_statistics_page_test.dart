import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/features/workouts/workout_statistics_page.dart';

import '../../support/fake_workout_repository.dart';

void main() {
  testWidgets('shows loading then an empty-history state', (tester) async {
    final repository = _DeferredWorkoutRepository();
    await tester.pumpWidget(
      MaterialApp(home: WorkoutStatisticsPage(repository: repository)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.completer.complete([]);
    await tester.pumpAndSettle();
    expect(
      find.text('Save a workout to start building your statistics.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows exercise summaries and switches progress periods/metrics',
    (tester) async {
      final repository = FakeWorkoutRepository();
      await repository.save(
        Workout(
          id: 1,
          date: DateTime(2026, 3, 2),
          exercises: [
            Exercise(
              name: 'Bench Press',
              libraryExerciseId: 8,
              sets: [
                WorkoutSet(weight: 50, reps: 8),
                WorkoutSet(weight: 45, reps: 10, setNumber: 2),
              ],
            ),
          ],
        ),
      );
      await repository.save(
        Workout(
          id: 2,
          date: DateTime(2026, 3, 5),
          exercises: [
            Exercise(
              name: 'Bench Press',
              libraryExerciseId: 8,
              sets: [WorkoutSet(weight: 60, reps: 5, setNumber: 3)],
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: WorkoutStatisticsPage(repository: repository)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workout Statistics'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('workout-progress-chart')),
        findsOneWidget,
      );
      await tester.tap(find.text('12 months'));
      await tester.pumpAndSettle();
      expect(find.text('Last 12 months'), findsOneWidget);
      await tester.tap(find.text('Volume'));
      await tester.pumpAndSettle();
      expect(
        find.text('External-load volume (kg × reps) per period'),
        findsOneWidget,
      );

      await tester.drag(
        find.byKey(const ValueKey('workout-statistics-list')),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('exercise-stat-8')));
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('2 sessions · 3 sets · 23 reps'), findsOneWidget);
      expect(find.text('1150 kg×reps'), findsOneWidget);
    },
  );

  testWidgets('refresh reflects saved workout edits and deletions', (
    tester,
  ) async {
    final repository = FakeWorkoutRepository();
    await repository.save(
      Workout(
        id: 1,
        date: DateTime(2026, 3, 2),
        exercises: [
          Exercise(
            name: 'Squat',
            libraryExerciseId: 3,
            sets: [
              WorkoutSet(weight: 60, reps: 5),
              WorkoutSet(weight: 40, reps: 8, setNumber: 2),
            ],
          ),
        ],
      ),
    );
    await repository.save(
      Workout(
        id: 2,
        date: DateTime(2026, 3, 3),
        exercises: [
          Exercise(
            name: 'Squat',
            libraryExerciseId: 3,
            sets: [WorkoutSet(weight: 50, reps: 4, setNumber: 3)],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: WorkoutStatisticsPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('workout-statistics-list')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('exercise-stat-3')));
    expect(find.text('2 sessions · 3 sets · 17 reps'), findsOneWidget);
    expect(find.text('820 kg×reps'), findsOneWidget);

    await repository.update(
      Workout(
        id: 1,
        date: DateTime(2026, 3, 2),
        exercises: [
          Exercise(
            name: 'Squat',
            libraryExerciseId: 3,
            sets: [WorkoutSet(weight: 60, reps: 5)],
          ),
        ],
      ),
    );
    await tester.tap(find.byKey(const ValueKey('refresh-workout-statistics')));
    await tester.pumpAndSettle();
    expect(find.text('2 sessions · 2 sets · 9 reps'), findsOneWidget);
    expect(find.text('500 kg×reps'), findsOneWidget);

    await repository.delete(2);
    await tester.tap(find.byKey(const ValueKey('refresh-workout-statistics')));
    await tester.pumpAndSettle();
    expect(find.text('1 session · 1 set · 5 reps'), findsOneWidget);
    expect(find.text('300 kg×reps'), findsOneWidget);
  });

  testWidgets('shows repository errors and supports retry', (tester) async {
    final repository = _FlakyWorkoutRepository();
    await tester.pumpWidget(
      MaterialApp(home: WorkoutStatisticsPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load workout statistics.'), findsOneWidget);

    repository.shouldFail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(
      find.text('Save a workout to start building your statistics.'),
      findsOneWidget,
    );
  });
}

class _DeferredWorkoutRepository extends FakeWorkoutRepository {
  final Completer<List<Workout>> completer = Completer<List<Workout>>();

  @override
  Future<List<Workout>> getAll() => completer.future;
}

class _FlakyWorkoutRepository extends FakeWorkoutRepository {
  bool shouldFail = true;

  @override
  Future<List<Workout>> getAll() async {
    if (shouldFail) throw StateError('Temporary load failure.');
    return super.getAll();
  }
}
