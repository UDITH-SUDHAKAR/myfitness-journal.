import '../models/exercise_library_item.dart';

/// Operations used by the exercise library and workout exercise picker.
abstract interface class ExerciseLibraryRepository {
  /// Saves a new entry and returns its ID.
  Future<int> save(ExerciseLibraryItem item);

  /// Returns all library entries, optionally matching [query] by name.
  Future<List<ExerciseLibraryItem>> search(String query);

  /// Updates an existing entry, or returns false if it no longer exists.
  Future<bool> update(ExerciseLibraryItem item);

  /// Deletes an entry, or returns false if it was not found.
  Future<bool> delete(int id);
}
