import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/exercise.dart';
import '../../core/models/workout.dart';
import '../../core/models/workout_set.dart';
import '../../core/models/previous_performance.dart';
import '../../core/models/exercise_library_item.dart';
import '../../core/storage/exercise_library_repository.dart';
import '../../core/storage/workout_repository.dart';
import 'exercise_library_page.dart';

/// Edits a new workout draft or shows a saved workout's details.
class WorkoutEditor extends StatefulWidget {
  /// Creates an editor for [workout].
  const WorkoutEditor({
    required this.workout,
    required this.repository,
    required this.exerciseLibraryRepository,
    required this.isNewWorkout,
    required this.isReadOnly,
    required this.onSave,
    required this.onEdit,
    required this.onCancel,
    super.key,
  });

  /// The draft being created or edited. The parent passes it as a copy so
  /// changes stay local until the user explicitly saves.
  final Workout workout;

  /// Loads read-only performance from earlier saved workouts.
  final WorkoutRepository repository;

  /// Loads library items and optionally saves custom exercises.
  final ExerciseLibraryRepository exerciseLibraryRepository;

  /// Whether this workout has not been saved before.
  final bool isNewWorkout;

  /// Whether controls that change the workout should be disabled.
  final bool isReadOnly;

  /// Saves a validated workout.
  final Future<void> Function(Workout workout) onSave;

  /// Switches a saved workout from details to edit mode.
  final VoidCallback onEdit;

  /// Closes the editor without saving its current draft.
  final VoidCallback onCancel;

  @override
  State<WorkoutEditor> createState() => _WorkoutEditorState();
}

class _WorkoutEditorState extends State<WorkoutEditor> {
  final _formKey = GlobalKey<FormState>();
  final Map<Exercise, PreviousPerformance?> _previousPerformances = {};
  final Set<Exercise> _previousPerformanceLoading = {};
  final Set<Exercise> _previousPerformanceErrors = {};
  int _previousPerformanceGeneration = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (final exercise in widget.workout.exercises) {
      _previousPerformanceLoading.add(exercise);
      unawaited(
        _loadPreviousPerformance(
          exercise,
          generation: _previousPerformanceGeneration,
        ),
      );
    }
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.workout.date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null && mounted) {
      widget.workout.date = date;
      _refreshPreviousPerformances();
    }
  }

  void _refreshPreviousPerformances() {
    _previousPerformanceGeneration++;
    final exercises = List<Exercise>.of(widget.workout.exercises);
    setState(() {
      _previousPerformances.clear();
      _previousPerformanceErrors.clear();
      _previousPerformanceLoading
        ..clear()
        ..addAll(exercises);
    });
    for (final exercise in exercises) {
      unawaited(
        _loadPreviousPerformance(
          exercise,
          generation: _previousPerformanceGeneration,
        ),
      );
    }
  }

  Future<void> _loadPreviousPerformance(
    Exercise exercise, {
    required int generation,
  }) async {
    try {
      final performance = await widget.repository.getPreviousPerformance(
        exercise: exercise,
        beforeDate: widget.workout.date,
      );
      if (!mounted || generation != _previousPerformanceGeneration) return;
      setState(() {
        _previousPerformances[exercise] = performance;
        _previousPerformanceLoading.remove(exercise);
        _previousPerformanceErrors.remove(exercise);
      });
    } catch (_) {
      if (!mounted || generation != _previousPerformanceGeneration) return;
      setState(() {
        _previousPerformanceLoading.remove(exercise);
        _previousPerformanceErrors.add(exercise);
      });
    }
  }

  Future<void> _addExercise() async {
    final selection = await showDialog<ExerciseLibraryItem?>(
      context: context,
      builder: (_) =>
          _ExercisePicker(repository: widget.exerciseLibraryRepository),
    );
    if (selection != null && mounted) {
      late Exercise exercise;
      setState(() {
        exercise = Exercise(
          name: selection.name,
          libraryExerciseId: selection.id < 0 ? null : selection.id,
          sets: <WorkoutSet>[],
        );
        widget.workout.exercises.add(exercise);
        _previousPerformanceLoading.add(exercise);
      });
      unawaited(
        _loadPreviousPerformance(
          exercise,
          generation: _previousPerformanceGeneration,
        ),
      );
    }
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final sets = widget.workout.exercises[exerciseIndex].sets;
      sets.add(WorkoutSet(setNumber: sets.length + 1));
    });
  }

  Future<void> _removeSet(int exerciseIndex, int setIndex) async {
    final shouldRemove = await _confirmRemoval(
      title: 'Delete set?',
      message: 'This set will be removed from the exercise.',
    );
    if (!shouldRemove || !mounted) return;

    setState(() {
      final sets = widget.workout.exercises[exerciseIndex].sets;
      sets.removeAt(setIndex);
      _renumberSets(sets);
    });
  }

  Future<void> _removeExercise(int exerciseIndex) async {
    final shouldRemove = await _confirmRemoval(
      title: 'Remove exercise?',
      message: 'Its sets will be removed from this workout.',
    );
    if (!shouldRemove || !mounted) return;

    setState(() => widget.workout.exercises.removeAt(exerciseIndex));
  }

  Future<bool> _confirmRemoval({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                key: const ValueKey('cancel-removal'),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const ValueKey('confirm-removal'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _renumberSets(List<WorkoutSet> sets) {
    for (var index = 0; index < sets.length; index++) {
      sets[index].setNumber = index + 1;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.workout.exercises.isEmpty) {
      _showMessage('Add at least one exercise before saving.');
      return;
    }
    if (widget.workout.exercises.any((exercise) => exercise.sets.isEmpty)) {
      _showMessage('Add at least one set to each exercise before saving.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSave(widget.workout);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatWeight(double weight) {
    return weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toString();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isReadOnly
        ? 'Workout details'
        : widget.isNewWorkout
        ? 'New workout'
        : 'Edit workout';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              IconButton(
                key: const ValueKey('close-workout-editor'),
                onPressed: widget.onCancel,
                tooltip: 'Back to workout history',
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  DateFormat('EEEE, d MMMM yyyy').format(widget.workout.date),
                ),
                trailing: widget.isReadOnly
                    ? null
                    : TextButton.icon(
                        key: const ValueKey('choose-workout-date'),
                        onPressed: _chooseDate,
                        icon: const Icon(Icons.edit_calendar_outlined),
                        label: const Text('Change'),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (widget.workout.exercises.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No exercises added yet.'),
              ),
            ),
          ...List.generate(
            widget.workout.exercises.length,
            (exerciseIndex) => _buildExerciseCard(exerciseIndex),
          ),
          if (!widget.isReadOnly)
            OutlinedButton.icon(
              key: const ValueKey('add-exercise'),
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add exercise'),
            ),
          const SizedBox(height: 12),
          if (widget.isReadOnly)
            FilledButton.icon(
              key: const ValueKey('edit-workout'),
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit workout'),
            )
          else
            FilledButton.icon(
              key: ValueKey(
                widget.isNewWorkout ? 'save-workout' : 'save-workout-changes',
              ),
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(
                _isSaving
                    ? 'Saving...'
                    : widget.isNewWorkout
                    ? 'Save workout'
                    : 'Save changes',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int exerciseIndex) {
    final exercise = widget.workout.exercises[exerciseIndex];

    return Card(
      key: ValueKey('exercise-${exercise.name}-$exerciseIndex'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!widget.isReadOnly)
                  IconButton(
                    key: ValueKey('remove-exercise-$exerciseIndex'),
                    tooltip: 'Remove ${exercise.name}',
                    onPressed: () => _removeExercise(exerciseIndex),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            if (exercise.sets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No sets added yet.'),
              ),
            _buildPreviousPerformance(exercise),
            ...List.generate(
              exercise.sets.length,
              (setIndex) => _buildSetRow(exerciseIndex, setIndex),
            ),
            if (!widget.isReadOnly)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: ValueKey('add-set-$exerciseIndex'),
                  onPressed: () => _addSet(exerciseIndex),
                  icon: const Icon(Icons.add),
                  label: const Text('Add set'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousPerformance(Exercise exercise) {
    final performance = _previousPerformances[exercise];
    final isLoading = _previousPerformanceLoading.contains(exercise);
    final hasError = _previousPerformanceErrors.contains(exercise);

    return Container(
      key: ValueKey('previous-performance-${exercise.name}'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Previous session',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (performance != null) ...[
                const SizedBox(width: 6),
                Text(
                  '· ${DateFormat('d MMM yyyy').format(performance.date)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (isLoading)
            Text(
              'Loading previous sets…',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else if (hasError)
            Text(
              'Previous performance could not be loaded.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else if (performance == null || performance.sets.isEmpty)
            Text(
              'No previous sets recorded.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            ...performance.sets.map(
              (set) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Set ${set.setNumber}: ${_formatWeight(set.weight)} kg × '
                  '${set.reps} reps',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex) {
    final set = widget.workout.exercises[exerciseIndex].sets[setIndex];

    return Padding(
      key: ObjectKey(set),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Set ${set.setNumber}'),
            ),
          ),
          Expanded(
            child: TextFormField(
              key: ValueKey('set-weight-$exerciseIndex-$setIndex'),
              initialValue: _formatWeight(set.weight),
              readOnly: widget.isReadOnly,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              validator: (value) {
                final weight = double.tryParse(value ?? '');
                if (weight == null || weight < 0) {
                  return 'Enter a weight of 0 or more';
                }
                return null;
              },
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null && weight >= 0) set.weight = weight;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              key: ValueKey('set-reps-$exerciseIndex-$setIndex'),
              initialValue: set.reps == 0 ? '' : set.reps.toString(),
              readOnly: widget.isReadOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reps'),
              validator: (value) {
                final reps = int.tryParse(value ?? '');
                if (reps == null || reps < 1) return 'Enter 1 or more reps';
                return null;
              },
              onChanged: (value) {
                final reps = int.tryParse(value);
                if (reps != null && reps > 0) set.reps = reps;
              },
            ),
          ),
          if (!widget.isReadOnly)
            IconButton(
              key: ValueKey('remove-set-$exerciseIndex-${set.setNumber - 1}'),
              tooltip: 'Delete set ${set.setNumber}',
              onPressed: () => _removeSet(exerciseIndex, setIndex),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }
}

class _ExercisePicker extends StatefulWidget {
  const _ExercisePicker({required this.repository});
  final ExerciseLibraryRepository repository;

  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  final _search = TextEditingController();
  List<ExerciseLibraryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await widget.repository.search(_search.text);
    if (mounted) setState(() => _items = items);
  }

  Future<void> _addCustom() async {
    var enteredName = '';
    var saveToLibrary = false;
    final item = await showDialog<ExerciseLibraryItem>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Custom exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('exercise-name-input'),
                autofocus: true,
                onChanged: (value) => enteredName = value,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Exercise name'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: saveToLibrary,
                title: const Text('Save to exercise library'),
                onChanged: (value) =>
                    setDialogState(() => saveToLibrary = value ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const ValueKey('confirm-add-exercise'),
              onPressed: () {
                final name = enteredName.trim();
                if (name.isEmpty) return;
                Navigator.pop(
                  context,
                  ExerciseLibraryItem(
                    id: saveToLibrary ? -1 : -2,
                    name: name,
                    muscleGroup: 'Other',
                    equipment: 'Other',
                  ),
                );
              },
              child: const Text('Add exercise'),
            ),
          ],
        ),
      ),
    );
    if (item == null || !mounted) return;
    if (item.id == -1) item.id = await widget.repository.save(item);
    if (!mounted) return;
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Choose exercise'),
    content: SizedBox(
      width: 420,
      height: 380,
      child: Column(
        children: [
          TextField(
            key: const ValueKey('exercise-library-search'),
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'Search library',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => _load(),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No matching exercises'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.muscleGroup} • ${item.equipment}',
                        ),
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  ),
          ),
          TextButton.icon(
            key: const ValueKey('add-custom-exercise'),
            onPressed: _addCustom,
            icon: const Icon(Icons.edit),
            label: const Text('Add custom exercise'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    ExerciseLibraryPage(repository: widget.repository),
              ),
            ).then((_) => _load()),
            icon: const Icon(Icons.library_add),
            label: const Text('Manage library'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ],
  );
}
