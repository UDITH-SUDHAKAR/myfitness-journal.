import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/workout.dart';
import '../models/exercise_library_item.dart';

/// Opens and provides the app's Isar database instance.
class IsarService {
  IsarService._();

  /// The shared service instance used by the application.
  static final IsarService instance = IsarService._();

  Isar? _database;

  /// The initialized database, or an error if initialization has not run yet.
  Isar get database {
    final database = _database;
    if (database == null) {
      throw StateError('IsarService.initialize() must be called first.');
    }
    return database;
  }

  /// Opens Isar in the app's documents directory and returns the instance.
  Future<Isar> initialize() async {
    if (_database != null) {
      return _database!;
    }

    final directory = await getApplicationDocumentsDirectory();
    _database = await Isar.open([
      WorkoutSchema,
      ExerciseLibraryItemSchema,
    ], directory: directory.path);
    return _database!;
  }
}
