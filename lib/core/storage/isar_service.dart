import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/workout.dart';
import '../models/exercise_library_item.dart';
import '../models/body_weight_entry.dart';
import '../models/nutrition_entry.dart';
import '../models/food.dart';
import '../models/meal.dart';

/// Opens and provides the app's Isar database instance.
class IsarService {
  IsarService({Future<Directory> Function()? directoryProvider})
    : _directoryProvider =
          directoryProvider ?? getApplicationDocumentsDirectory;

  IsarService._() : _directoryProvider = getApplicationDocumentsDirectory;

  /// The shared service instance used by the application.
  static final IsarService instance = IsarService._();

  final Future<Directory> Function() _directoryProvider;
  final Map<String, Future<Isar>> _databases = {};

  /// The initialized database, or an error if initialization has not run yet.
  Isar get database {
    final database = Isar.getInstance(Isar.defaultName);
    if (database == null) {
      throw StateError('IsarService.initialize() must be called first.');
    }
    return database;
  }

  /// Opens the original device-only database in the app documents directory.
  ///
  /// The default Isar name and path are kept so existing records remain
  /// available when a user chooses Continue Offline.
  Future<Isar> initialize() async {
    return openOffline();
  }

  /// Opens the original local database used by Continue Offline.
  Future<Isar> openOffline() =>
      _open(cacheKey: 'offline', databaseName: Isar.defaultName);

  /// Opens a separate Isar database for one Supabase user.
  ///
  /// Each authenticated user ID maps to a stable local database name. The
  /// database uses the existing schemas but never shares records with the
  /// offline store or another account.
  Future<Isar> openForUser(String userId) {
    if (userId.isEmpty || !RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(userId)) {
      throw ArgumentError.value(userId, 'userId', 'Invalid Supabase user ID.');
    }
    return _open(cacheKey: 'user:$userId', databaseName: 'user_$userId');
  }

  Future<Isar> _open({required String cacheKey, required String databaseName}) {
    final cached = _databases[cacheKey];
    if (cached != null) return cached;

    late final Future<Isar> opening;
    opening =
        (() async {
          final directory = await _directoryProvider();
          final existing = Isar.getInstance(databaseName);
          if (existing != null) return existing;
          return Isar.open(
            _schemas,
            directory: directory.path,
            name: databaseName,
          );
        })().catchError((Object error, StackTrace stackTrace) {
          _databases.remove(cacheKey);
          Error.throwWithStackTrace(error, stackTrace);
        });
    _databases[cacheKey] = opening;
    return opening;
  }

  /// Closes instances owned by this service. Primarily useful in tests.
  Future<void> closeAll() async {
    final databases = await Future.wait(_databases.values);
    _databases.clear();
    for (final database in databases) {
      await database.close();
    }
  }

  static final List<CollectionSchema<dynamic>> _schemas = [
    WorkoutSchema,
    ExerciseLibraryItemSchema,
    BodyWeightEntrySchema,
    NutritionEntrySchema,
    FoodSchema,
    MealSchema,
  ];
}
