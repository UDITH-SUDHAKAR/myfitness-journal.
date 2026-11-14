import 'package:flutter/material.dart';

import '../../core/models/exercise.dart';
import '../../core/models/workout.dart';
import '../../core/models/workout_set.dart';
import '../../core/storage/workout_repository.dart';
import '../../core/storage/exercise_library_repository.dart';
import 'workout_editor.dart';
import 'workout_history.dart';

enum _EditorMode { creating, viewing, editing }

/// Connects workout creation and history to the local workout repository.
class WorkoutPage extends StatefulWidget {
  /// Creates the workout page using the app's repository.
  const WorkoutPage({
    required this.repository,
    required this.exerciseLibraryRepository,
    required this.selectedDate,
    required this.onWorkoutsChanged,
    super.key,
  });

  /// Loads and saves persisted workout records.
  final WorkoutRepository repository;

  /// Provides reusable exercise definitions to the workout editor.
  final ExerciseLibraryRepository exerciseLibraryRepository;

  /// Date selected in the app's date navigation.
  final DateTime selectedDate;

  /// Lets the home screen refresh its workout summary.
  final ValueChanged<List<Workout>> onWorkoutsChanged;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Workout> _workouts = [];
  Workout? _activeWorkout;
  _EditorMode? _editorMode;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      final workouts = await widget.repository.getAll();
      workouts.sort((first, second) => second.date.compareTo(first.date));
      if (!mounted) return;

      setState(() {
        _workouts = workouts;
        _isLoading = false;
        _loadError = null;
      });
      widget.onWorkoutsChanged(List<Workout>.unmodifiable(workouts));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString();
      });
    }
  }

  void _startWorkout() {
    setState(() {
      _activeWorkout = Workout(
        date: DateUtils.dateOnly(widget.selectedDate),
        exercises: <Exercise>[],
      );
      _editorMode = _EditorMode.creating;
    });
  }

  void _openWorkout(Workout workout) {
    setState(() {
      // Work on a copy so simply opening a record cannot change saved data.
      _activeWorkout = _copyWorkout(workout);
      _editorMode = _EditorMode.viewing;
    });
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

  Future<void> _closeEditor() async {
    final mode = _editorMode;
    if (mode == _EditorMode.creating || mode == _EditorMode.editing) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('Your unsaved workout changes will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              key: const ValueKey('confirm-discard-workout'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }

    setState(() {
      _activeWorkout = null;
      _editorMode = null;
    });
  }

  Future<void> _saveWorkout(Workout workout) async {
    try {
      final mode = _editorMode;

      if (mode == _EditorMode.creating) {
        await widget.repository.save(workout);
      } else if (mode == _EditorMode.editing) {
        // Viewing is read-only. Editing is a separate action and saving those
        // edits asks for confirmation before replacing the existing record.
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Save changes?'),
            content: const Text('This will update the saved workout.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const ValueKey('confirm-save-workout-changes'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Save changes'),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;

        final updated = await widget.repository.update(workout);
        if (!updated) {
          _showMessage('This workout no longer exists. History was refreshed.');
          await _loadWorkouts();
          if (mounted) {
            setState(() {
              _activeWorkout = null;
              _editorMode = null;
            });
          }
          return;
        }
      } else {
        return;
      }

      await _loadWorkouts();
      if (!mounted) return;

      setState(() {
        _activeWorkout = null;
        _editorMode = null;
      });
    } catch (error) {
      if (mounted) _showMessage('Could not save workout: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_editorMode != null && _activeWorkout != null) {
      return WorkoutEditor(
        key: ValueKey('workout-editor-${_activeWorkout!.id}-$_editorMode'),
        workout: _activeWorkout!,
        exerciseLibraryRepository: widget.exerciseLibraryRepository,
        isNewWorkout: _editorMode == _EditorMode.creating,
        isReadOnly: _editorMode == _EditorMode.viewing,
        onSave: _saveWorkout,
        onEdit: () => setState(() => _editorMode = _EditorMode.editing),
        onCancel: _closeEditor,
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load workout history.'),
              const SizedBox(height: 8),
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadWorkouts,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    return WorkoutHistory(
      workouts: _workouts,
      onOpenWorkout: _openWorkout,
      onCreateWorkout: _startWorkout,
    );
  }
}
