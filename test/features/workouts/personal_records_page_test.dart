import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/features/workouts/personal_records_page.dart';

import '../../support/fake_workout_repository.dart';

void main() {
  testWidgets('shows calculated records with dates and load context', (
    tester,
  ) async {
    final repository = FakeWorkoutRepository();
    await repository.save(
      Workout(
        date: DateTime(2026, 6, 10),
        exercises: [
          Exercise(
            name: 'Bench Press',
            sets: [
              WorkoutSet(weight: 0, reps: 15),
              WorkoutSet(weight: 70, reps: 5, setNumber: 2),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: PersonalRecordsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personal Records'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Heaviest set'), findsOneWidget);
    expect(find.text('70 kg × 5 reps'), findsOneWidget);
    expect(find.text('Most reps'), findsOneWidget);
    expect(find.text('15 reps at 0 kg'), findsOneWidget);
    expect(find.text('10 Jun 2026'), findsNWidgets(2));
  });

  testWidgets('shows an empty message when there are no valid saved sets', (
    tester,
  ) async {
    final repository = FakeWorkoutRepository();

    await tester.pumpWidget(
      MaterialApp(home: PersonalRecordsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Log completed sets to start building records.'),
      findsOneWidget,
    );
  });
}
