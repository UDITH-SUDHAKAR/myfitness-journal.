import '../models/workout.dart';

/// The operations the UI needs for loading and saving workouts.
///
/// Keeping this small interface separate lets widget tests use a simple fake
/// repository without starting the native database.
abstract interface class WorkoutRepository {
  /// Saves a new workout and returns its unique ID.
  Future<int> save(Workout workout);

  /// Returns all saved workouts.
  Future<List<Workout>> getAll();

  /// Returns the workout with [id], or `null` if it does not exist.
  Future<Workout?> getById(int id);

  /// Replaces an existing workout. Returns `false` if it was not found.
  Future<bool> update(Workout workout);

  /// Deletes a workout. Returns `false` if it was not found.
  Future<bool> delete(int id);
}
