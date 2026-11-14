import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/features/workouts/personal_record_calculator.dart';

void main() {
  test('calculates heaviest positive set and most reps with load context', () {
    final workouts = [
      Workout(
        id: 1,
        date: DateTime(2026, 4, 1),
        exercises: [
          Exercise(
            name: 'Bench Press',
            sets: [
              WorkoutSet(weight: 0, reps: 20),
              WorkoutSet(weight: 50, reps: 8, setNumber: 2),
              WorkoutSet(weight: 75, reps: 3, setNumber: 3),
              WorkoutSet(weight: -5, reps: 100, setNumber: 4),
              WorkoutSet(weight: 100, reps: 0, setNumber: 5),
            ],
          ),
        ],
      ),
    ];

    final records = PersonalRecordCalculator.calculate(workouts).single;

    expect(records.heaviestSet!.weight, 75);
    expect(records.heaviestSet!.reps, 3);
    expect(records.mostReps!.reps, 20);
    expect(records.mostReps!.weight, 0);
    expect(records.mostReps!.date, DateTime(2026, 4, 1));
  });

  test(
    'equal values keep the earlier record and do not create a higher best',
    () {
      final records = PersonalRecordCalculator.calculate([
        Workout(
          id: 1,
          date: DateTime(2026, 4, 1),
          exercises: [
            Exercise(name: 'Squat', sets: [WorkoutSet(weight: 100, reps: 5)]),
          ],
        ),
        Workout(
          id: 2,
          date: DateTime(2026, 4, 8),
          exercises: [
            Exercise(name: 'Squat', sets: [WorkoutSet(weight: 100, reps: 5)]),
          ],
        ),
      ]).single;

      expect(records.heaviestSet!.date, DateTime(2026, 4, 1));
      expect(records.mostReps!.date, DateTime(2026, 4, 1));
    },
  );

  test(
    'different non-null library IDs stay separate despite identical names',
    () {
      final workouts = [
        Workout(
          id: 1,
          date: DateTime(2026, 4, 1),
          exercises: [
            Exercise(
              name: 'Cable Press',
              libraryExerciseId: 11,
              sets: [WorkoutSet(weight: 20, reps: 12)],
            ),
          ],
        ),
        Workout(
          id: 2,
          date: DateTime(2026, 4, 2),
          exercises: [
            Exercise(
              name: 'Cable Press',
              libraryExerciseId: 22,
              sets: [WorkoutSet(weight: 40, reps: 6)],
            ),
          ],
        ),
        Workout(
          id: 3,
          date: DateTime(2026, 4, 3),
          exercises: [
            Exercise(
              name: 'Cable Press',
              sets: [WorkoutSet(weight: 30, reps: 10)],
            ),
          ],
        ),
      ];

      final records = PersonalRecordCalculator.calculate(workouts);

      expect(records, hasLength(3));
      expect(
        PersonalRecordCalculator.forExercise(
          records,
          Exercise(name: 'Cable Press', libraryExerciseId: 11),
        )!.heaviestSet!.weight,
        20,
      );
      expect(
        PersonalRecordCalculator.forExercise(
          records,
          Exercise(name: 'Cable Press', libraryExerciseId: 22),
        )!.heaviestSet!.weight,
        40,
      );
      expect(
        PersonalRecordCalculator.forExercise(
          records,
          Exercise(name: 'Cable Press'),
        )!.heaviestSet!.weight,
        30,
      );
    },
  );

  test(
    'merges a normalized custom name into one unambiguous library record',
    () {
      final records = PersonalRecordCalculator.calculate([
        Workout(
          id: 1,
          date: DateTime(2026, 4, 1),
          exercises: [
            Exercise(
              name: 'Dumbbell Row',
              libraryExerciseId: 12,
              sets: [WorkoutSet(weight: 35, reps: 8)],
            ),
          ],
        ),
        Workout(
          id: 2,
          date: DateTime(2026, 4, 2),
          exercises: [
            Exercise(
              name: '  dumbbell   row ',
              sets: [WorkoutSet(weight: 40, reps: 6)],
            ),
          ],
        ),
      ]);

      expect(records, hasLength(1));
      expect(records.single.libraryExerciseId, 12);
      expect(records.single.heaviestSet!.weight, 40);
    },
  );

  test('can exclude an edited workout from the saved-record baseline', () {
    final workouts = [
      Workout(
        id: 1,
        date: DateTime(2026, 4, 1),
        exercises: [
          Exercise(name: 'Deadlift', sets: [WorkoutSet(weight: 80, reps: 5)]),
        ],
      ),
      Workout(
        id: 2,
        date: DateTime(2026, 4, 2),
        exercises: [
          Exercise(name: 'Deadlift', sets: [WorkoutSet(weight: 100, reps: 3)]),
        ],
      ),
    ];

    final records = PersonalRecordCalculator.calculate(
      workouts,
      excludeWorkoutId: 2,
    ).single;

    expect(records.heaviestSet!.weight, 80);
    expect(records.mostReps!.reps, 5);
  });
}
