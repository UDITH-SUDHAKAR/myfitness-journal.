import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/features/workouts/workout_history.dart';
import 'package:myfitness_journal/features/workouts/workout_history_filter.dart';

void main() {
  final olderWorkout = Workout(
    id: 1,
    date: DateTime(2026, 7, 31, 23, 30),
    exercises: [
      Exercise(
        name: 'Squat',
        sets: [
          WorkoutSet(weight: 60, reps: 8),
          WorkoutSet(weight: 65, reps: 6, setNumber: 2),
        ],
      ),
    ],
  );
  final benchWorkout = Workout(
    id: 2,
    date: DateTime(2026, 8, 1, 10),
    exercises: [
      Exercise(name: 'Bench Press', sets: [WorkoutSet(weight: 40, reps: 10)]),
      Exercise(name: 'Cable Row', sets: [WorkoutSet(weight: 30, reps: 12)]),
    ],
  );
  final mostRecentWorkout = Workout(
    id: 3,
    date: DateTime(2026, 8, 14),
    exercises: [
      Exercise(
        name: 'Incline Bench Press',
        sets: [
          WorkoutSet(weight: 35, reps: 12),
          WorkoutSet(weight: 40, reps: 8, setNumber: 2),
        ],
      ),
    ],
  );

  Future<void> pumpHistory(
    WidgetTester tester, {
    required List<Workout> workouts,
    ValueChanged<Workout>? onOpenWorkout,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutHistory(
            workouts: workouts,
            onOpenWorkout: onOpenWorkout ?? (_) {},
            onCreateWorkout: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('groups workouts by month and shows useful summaries', (
    tester,
  ) async {
    Workout? openedWorkout;
    await pumpHistory(
      tester,
      workouts: [olderWorkout, benchWorkout, mostRecentWorkout],
      onOpenWorkout: (workout) => openedWorkout = workout,
    );

    final augustHeader = find.text('August 2026');
    final julyHeader = find.text('July 2026');
    expect(augustHeader, findsOneWidget);
    expect(julyHeader, findsOneWidget);
    expect(
      tester.getTopLeft(augustHeader).dy,
      lessThan(tester.getTopLeft(julyHeader).dy),
    );

    expect(find.text('1 exercise · 2 sets'), findsNWidgets(2));
    expect(find.text('2 exercises · 2 sets'), findsOneWidget);
    expect(find.text('Bench Press · Cable Row'), findsOneWidget);
    expect(find.text('Incline Bench Press'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('workout-2')));
    expect(openedWorkout, same(benchWorkout));
  });

  testWidgets('search is case-insensitive and reports no matching workouts', (
    tester,
  ) async {
    await pumpHistory(
      tester,
      workouts: [olderWorkout, benchWorkout, mostRecentWorkout],
    );

    await tester.enterText(
      find.byKey(const ValueKey('workout-history-search')),
      'bEnCh',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('workout-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('workout-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('workout-1')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('workout-history-search')),
      'rowing',
    );
    await tester.pumpAndSettle();
    expect(find.text('No workouts match these filters.'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('clear-workout-history-filters')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('workout-1')), findsOneWidget);
  });

  testWidgets('shows the original empty history state when no workouts exist', (
    tester,
  ) async {
    await pumpHistory(tester, workouts: []);
    expect(find.text('Your saved workouts will appear here.'), findsOneWidget);
    expect(find.text('No workouts match these filters.'), findsNothing);
  });

  test(
    'date and exercise filters compose and include both calendar endpoints',
    () {
      final beforeRange = Workout(
        id: 4,
        date: DateTime(2026, 7, 31, 23, 59),
        exercises: [Exercise(name: 'Bench Press')],
      );
      final startBoundary = Workout(
        id: 5,
        date: DateTime(2026, 8, 1, 23, 59),
        exercises: [Exercise(name: 'Bench Press')],
      );
      final endBoundary = Workout(
        id: 6,
        date: DateTime(2026, 8, 14, 0, 1),
        exercises: [Exercise(name: 'Bench Press')],
      );
      final afterRange = Workout(
        id: 7,
        date: DateTime(2026, 8, 15),
        exercises: [Exercise(name: 'Bench Press')],
      );
      final matches = WorkoutHistoryFilter.apply(
        workouts: [beforeRange, startBoundary, endBoundary, afterRange],
        exerciseName: 'bEnCh',
        dateRange: DateTimeRange(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 14),
        ),
      );

      expect(matches.map((workout) => workout.id), [5, 6]);
    },
  );
}
