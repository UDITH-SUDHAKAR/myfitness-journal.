import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';
import 'package:myfitness_journal/core/storage/workout_repository.dart';

/// Small in-memory repository used by widget tests.
class FakeWorkoutRepository implements WorkoutRepository {
  final List<Workout> _workouts = [];
  int _nextId = 1;

  @override
  Future<int> save(Workout workout) async {
    workout.id = _nextId++;
    _workouts.add(_copyWorkout(workout));
    return workout.id;
  }

  @override
  Future<List<Workout>> getAll() async {
    return _workouts.map(_copyWorkout).toList();
  }

  @override
  Future<Workout?> getById(int id) async {
    for (final workout in _workouts) {
      if (workout.id == id) return _copyWorkout(workout);
    }
    return null;
  }

  @override
  Future<bool> update(Workout workout) async {
    final index = _workouts.indexWhere((saved) => saved.id == workout.id);
    if (index == -1) return false;

    _workouts[index] = _copyWorkout(workout);
    return true;
  }

  @override
  Future<bool> delete(int id) async {
    final index = _workouts.indexWhere((workout) => workout.id == id);
    if (index == -1) return false;

    _workouts.removeAt(index);
    return true;
  }

  Workout _copyWorkout(Workout workout) {
    return Workout(
      id: workout.id,
      date: workout.date,
      exercises: workout.exercises
          .map(
            (exercise) => Exercise(
              name: exercise.name,
              libraryExerciseId: exercise.libraryExerciseId,
              sets: exercise.sets
                  .map(
                    (set) => WorkoutSet(
                      weight: set.weight,
                      reps: set.reps,
                      setNumber: set.setNumber,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
