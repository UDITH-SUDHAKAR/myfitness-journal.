import 'package:isar_community/isar.dart';

import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/previous_performance.dart';
import 'workout_repository.dart';

/// Isar-backed implementation of [WorkoutRepository].
class IsarWorkoutRepository implements WorkoutRepository {
  /// Creates a repository connected to an open Isar database.
  IsarWorkoutRepository(this._isar);

  final Isar _isar;

  @override
  Future<Id> save(Workout workout) {
    return _isar.writeTxn(() => _isar.workouts.put(workout));
  }

  @override
  Future<List<Workout>> getAll() {
    return _isar.workouts.where().findAll();
  }

  @override
  Future<Workout?> getById(Id id) {
    return _isar.workouts.get(id);
  }

  @override
  Future<bool> update(Workout workout) async {
    return _isar.writeTxn(() async {
      final existingWorkout = await _isar.workouts.get(workout.id);
      if (existingWorkout == null) {
        return false;
      }

      await _isar.workouts.put(workout);
      return true;
    });
  }

  @override
  Future<bool> delete(Id id) {
    return _isar.writeTxn(() => _isar.workouts.delete(id));
  }

  @override
  Future<PreviousPerformance?> getPreviousPerformance({
    required Exercise exercise,
    required DateTime beforeDate,
  }) async {
    final workouts = await getAll();
    return findPreviousPerformance(
      workouts: workouts,
      exercise: exercise,
      beforeDate: beforeDate,
    );
  }
}
