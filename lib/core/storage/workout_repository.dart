import 'package:isar_community/isar.dart';

import '../models/workout.dart';

/// Reads and writes workouts in the Isar database.
class WorkoutRepository {
  /// Creates a repository that uses the provided Isar database.
  WorkoutRepository(this._isar);

  final Isar _isar;

  /// Saves a new workout and returns its unique database ID.
  Future<Id> save(Workout workout) async {
    return _isar.writeTxn(() => _isar.workouts.put(workout));
  }

  /// Returns all saved workouts.
  Future<List<Workout>> getAll() {
    return _isar.workouts.where().findAll();
  }

  /// Returns the workout with [id], or `null` if it does not exist.
  Future<Workout?> getById(Id id) {
    return _isar.workouts.get(id);
  }

  /// Replaces an existing workout and its embedded exercises and sets.
  ///
  /// Returns `false` when no workout with the same ID exists.
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

  /// Deletes the workout with [id]. Returns `false` if it was not found.
  Future<bool> delete(Id id) {
    return _isar.writeTxn(() => _isar.workouts.delete(id));
  }
}
