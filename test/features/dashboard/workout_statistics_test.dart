import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/features/dashboard/workout_statistics.dart';

void main() {
  test('returns zeros and all seven weekdays for empty history', () {
    final statistics = WorkoutStatisticsCalculator.calculate(
      workouts: [],
      referenceDate: DateTime(2026, 11, 18),
    );

    expect(statistics.allTimeWorkoutCount, 0);
    expect(statistics.weeklyWorkoutCount, 0);
    expect(statistics.weeklyExerciseCount, 0);
    expect(statistics.weeklySetCount, 0);
    expect(statistics.weeklyRepCount, 0);
    expect(statistics.weeklyActivity, hasLength(7));
    expect(statistics.weeklyActivity.first.date.weekday, DateTime.monday);
    expect(statistics.weeklyActivity.last.date.weekday, DateTime.sunday);
  });

  test('uses calendar boundaries, counts sessions, and totals training', () {
    final workouts = [
      Workout(
        date: DateTime(2026, 11, 16, 23, 30), // Monday, late in the day.
        exercises: [
          Exercise(
            name: 'Squat',
            sets: [
              WorkoutSet(weight: 40, reps: 8),
              WorkoutSet(weight: 45, reps: 6, setNumber: 2),
            ],
          ),
          Exercise(name: 'Mobility'), // Exercise without sets still counts.
        ],
      ),
      Workout(
        date: DateTime(2026, 11, 16, 7), // A second Monday session.
        exercises: [
          Exercise(name: 'Bench', sets: [WorkoutSet(weight: 20, reps: 10)]),
        ],
      ),
      Workout(
        date: DateTime(2026, 11, 22, 23, 59), // Sunday is included.
        exercises: [Exercise(name: 'Run')],
      ),
      Workout(
        date: DateTime(2026, 11, 23), // Next Monday is excluded.
        exercises: [Exercise(name: 'Next week')],
      ),
    ];

    final statistics = WorkoutStatisticsCalculator.calculate(
      workouts: workouts,
      referenceDate: DateTime(2026, 11, 19),
    );

    expect(statistics.allTimeWorkoutCount, 4);
    expect(statistics.weeklyWorkoutCount, 3);
    expect(statistics.weeklyActivity.first.count, 2);
    expect(statistics.weeklyActivity.last.count, 1);
    expect(statistics.weeklyExerciseCount, 4);
    expect(statistics.weeklySetCount, 3);
    expect(statistics.weeklyRepCount, 24);
  });
}
