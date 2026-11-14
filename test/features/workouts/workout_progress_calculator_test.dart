import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/features/workouts/workout_progress_calculator.dart';

void main() {
  group('weeklyProgress', () {
    test('returns the latest 12 Monday-Sunday weeks, including endpoints', () {
      final workouts = [
        Workout(
          id: 1,
          date: DateTime(2026, 6, 15, 23, 59), // Monday.
          exercises: [
            Exercise(
              name: 'Squat',
              sets: [
                WorkoutSet(weight: 50, reps: 10),
                WorkoutSet(weight: 20, reps: 5, setNumber: 2),
                WorkoutSet(weight: 0, reps: 12, setNumber: 3),
                WorkoutSet(weight: -1, reps: 8, setNumber: 4),
                WorkoutSet(weight: double.nan, reps: 8, setNumber: 5),
                WorkoutSet(weight: double.infinity, reps: 8, setNumber: 6),
                WorkoutSet(weight: 100, reps: 0, setNumber: 7),
              ],
            ),
            Exercise(name: 'Mobility'),
          ],
        ),
        Workout(
          id: 2,
          date: DateTime(2026, 6, 15, 7), // Second session on Monday.
          exercises: [Exercise(name: 'Walk')],
        ),
        Workout(
          id: 3,
          date: DateTime(2026, 6, 21, 23, 59), // Sunday.
          exercises: [Exercise(name: 'Run')],
        ),
        Workout(
          id: 4,
          date: DateTime(2026, 6, 22),
          exercises: [],
        ), // Next week.
      ];

      final progress = WorkoutProgressCalculator.weeklyProgress(
        workouts: workouts,
        referenceDate: DateTime(2026, 6, 17),
      );

      expect(progress, hasLength(12));
      expect(progress.first.startDate, DateTime(2026, 3, 30));
      expect(progress.last.startDate, DateTime(2026, 6, 15));
      final currentWeek = progress.last;
      expect(currentWeek.workoutCount, 3);
      expect(currentWeek.exerciseCount, 4);
      expect(currentWeek.setCount, 7);
      expect(currentWeek.repCount, 51);
      expect(currentWeek.volumeKg, 600);
    });

    test('includes empty workouts as sessions and emits zero-filled weeks', () {
      final progress = WorkoutProgressCalculator.weeklyProgress(
        workouts: [Workout(id: 1, date: DateTime(2026, 6, 17), exercises: [])],
        referenceDate: DateTime(2026, 6, 17),
      );
      expect(progress, hasLength(12));
      expect(progress.last.workoutCount, 1);
      expect(progress.last.exerciseCount, 0);
      expect(progress.last.volumeKg, 0);
      expect(
        progress.take(11).every((summary) => summary.workoutCount == 0),
        isTrue,
      );
    });
  });

  test('monthlyProgress handles year boundaries and the 12-month window', () {
    final progress = WorkoutProgressCalculator.monthlyProgress(
      referenceDate: DateTime(2026, 2, 14),
      workouts: [
        Workout(id: 1, date: DateTime(2025, 2, 28), exercises: []),
        Workout(id: 2, date: DateTime(2025, 3, 31), exercises: []),
        Workout(id: 3, date: DateTime(2025, 12, 31), exercises: []),
        Workout(id: 4, date: DateTime(2026, 1, 1), exercises: []),
        Workout(id: 5, date: DateTime(2026, 2, 28), exercises: []),
        Workout(id: 6, date: DateTime(2026, 3, 1), exercises: []),
      ],
    );

    expect(progress, hasLength(12));
    expect(progress.first.startDate, DateTime(2025, 3));
    expect(progress.last.startDate, DateTime(2026, 2));
    expect(progress.first.workoutCount, 1);
    expect(progress[9].workoutCount, 1); // December 2025.
    expect(progress[10].workoutCount, 1); // January 2026.
    expect(progress.last.workoutCount, 1);
  });

  group('exerciseStatistics', () {
    test('counts distinct sessions, sets, reps, and valid external volume', () {
      final sameWorkout = Workout(
        id: 1,
        date: DateTime(2026, 1, 1),
        exercises: [
          Exercise(
            name: 'Squat',
            libraryExerciseId: 7,
            sets: [WorkoutSet(weight: 60, reps: 5)],
          ),
          Exercise(
            name: ' squat ',
            libraryExerciseId: 7,
            sets: [WorkoutSet(weight: 40, reps: 5, setNumber: 2)],
          ),
        ],
      );
      final anotherWorkoutSameDay = Workout(
        id: 2,
        date: DateTime(2026, 1, 1, 18),
        exercises: [
          Exercise(
            name: 'Squat',
            libraryExerciseId: 7,
            sets: [WorkoutSet(weight: 0, reps: 8, setNumber: 3)],
          ),
        ],
      );

      final result = WorkoutProgressCalculator.exerciseStatistics([
        sameWorkout,
        anotherWorkoutSameDay,
      ]).single;

      expect(result.sessionCount, 2);
      expect(result.setCount, 3);
      expect(result.repCount, 18);
      expect(result.volumeKg, 500);
    });

    test(
      'separates library IDs and merges a uniquely matching custom name',
      () {
        final results = WorkoutProgressCalculator.exerciseStatistics([
          Workout(
            id: 1,
            date: DateTime(2026, 1, 1),
            exercises: [
              Exercise(
                name: 'Cable Press',
                libraryExerciseId: 11,
                sets: [WorkoutSet(weight: 20, reps: 10)],
              ),
              Exercise(
                name: 'Cable Press',
                libraryExerciseId: 22,
                sets: [WorkoutSet(weight: 40, reps: 5)],
              ),
            ],
          ),
          Workout(
            id: 2,
            date: DateTime(2026, 1, 2),
            exercises: [
              Exercise(
                name: ' cable   press ',
                sets: [WorkoutSet(weight: 30, reps: 6)],
              ),
            ],
          ),
        ]);

        expect(results, hasLength(3));
        expect(results.map((entry) => entry.libraryExerciseId).toSet(), {
          11,
          22,
          null,
        });
        expect(
          results.firstWhere((entry) => entry.libraryExerciseId == 11).volumeKg,
          200,
        );
        expect(
          results.firstWhere((entry) => entry.libraryExerciseId == 22).volumeKg,
          200,
        );
        expect(
          results
              .firstWhere((entry) => entry.libraryExerciseId == null)
              .volumeKg,
          180,
        );
      },
    );

    test(
      'custom exercise joins one matching library group but not ambiguous IDs',
      () {
        final unique = WorkoutProgressCalculator.exerciseStatistics([
          Workout(
            id: 1,
            date: DateTime(2026, 1, 1),
            exercises: [
              Exercise(name: 'Row', libraryExerciseId: 4),
              Exercise(name: ' row '),
            ],
          ),
        ]);
        expect(unique, hasLength(1));
        expect(unique.single.libraryExerciseId, 4);
        expect(unique.single.sessionCount, 1);
        expect(unique.single.setCount, 0);

        final ambiguous = WorkoutProgressCalculator.exerciseStatistics([
          Workout(
            id: 1,
            date: DateTime(2026, 1, 1),
            exercises: [
              Exercise(name: 'Press', libraryExerciseId: 4),
              Exercise(name: 'Press', libraryExerciseId: 5),
              Exercise(name: ' press '),
            ],
          ),
        ]);
        expect(ambiguous, hasLength(3));
      },
    );
  });
}
