import 'package:myfitness_journal/core/models/exercise_library_item.dart';
import 'package:myfitness_journal/core/storage/exercise_library_repository.dart';

/// In-memory exercise library used by widget tests.
class FakeExerciseLibraryRepository implements ExerciseLibraryRepository {
  final List<ExerciseLibraryItem> items = [];
  int _nextId = 1;

  @override
  Future<int> save(ExerciseLibraryItem item) async {
    item.id = _nextId++;
    items.add(_copy(item));
    return item.id;
  }

  @override
  Future<List<ExerciseLibraryItem>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(normalized))
        .map(_copy)
        .toList();
  }

  @override
  Future<bool> update(ExerciseLibraryItem item) async {
    final index = items.indexWhere((saved) => saved.id == item.id);
    if (index < 0) return false;
    items[index] = _copy(item);
    return true;
  }

  @override
  Future<bool> delete(int id) async {
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    items.removeAt(index);
    return true;
  }

  ExerciseLibraryItem _copy(ExerciseLibraryItem item) => ExerciseLibraryItem(
    id: item.id,
    name: item.name,
    muscleGroup: item.muscleGroup,
    equipment: item.equipment,
    description: item.description,
  );
}
