import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/workout.dart';
import 'workout_history_filter.dart';

/// Searchable, date-filtered list of saved workouts.
class WorkoutHistory extends StatefulWidget {
  /// Creates a workout history list.
  const WorkoutHistory({
    required this.workouts,
    required this.onOpenWorkout,
    required this.onCreateWorkout,
    super.key,
  });

  /// Saved workouts, usually sorted from newest to oldest.
  final List<Workout> workouts;

  /// Opens a workout selected from the history.
  final ValueChanged<Workout> onOpenWorkout;

  /// Starts a new workout.
  final VoidCallback onCreateWorkout;

  @override
  State<WorkoutHistory> createState() => _WorkoutHistoryState();
}

class _WorkoutHistoryState extends State<WorkoutHistory> {
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _chooseDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 3650)),
      ),
      initialDateRange: _dateRange,
    );
    if (range != null && mounted) {
      setState(
        () => _dateRange = DateTimeRange(
          start: DateUtils.dateOnly(range.start),
          end: DateUtils.dateOnly(range.end),
        ),
      );
    }
  }

  List<Workout> get _filteredWorkouts {
    final filtered = WorkoutHistoryFilter.apply(
      workouts: widget.workouts,
      exerciseName: _searchController.text,
      dateRange: _dateRange,
    );
    filtered.sort((first, second) {
      final byDate = second.date.compareTo(first.date);
      return byDate != 0 ? byDate : second.id.compareTo(first.id);
    });
    return filtered;
  }

  Map<DateTime, List<Workout>> _groupByMonth(List<Workout> workouts) {
    final groups = <DateTime, List<Workout>>{};
    for (final workout in workouts) {
      final month = DateTime(workout.date.year, workout.date.month);
      groups.putIfAbsent(month, () => []).add(workout);
    }
    return groups;
  }

  String _dateRangeLabel() {
    final range = _dateRange;
    if (range == null) return 'All dates';
    final format = DateFormat('d MMM yyyy');
    return '${format.format(range.start)} – ${format.format(range.end)}';
  }

  Widget _buildWorkoutCard(Workout workout) {
    final exerciseCount = workout.exercises.length;
    final setCount = workout.exercises.fold<int>(
      0,
      (total, exercise) => total + exercise.sets.length,
    );
    final exercisePreview = workout.exercises.isEmpty
        ? 'No exercises logged'
        : '${workout.exercises.take(2).map((exercise) => exercise.name).join(' · ')}'
              '${exerciseCount > 2 ? ' + ${exerciseCount - 2} more' : ''}';

    return Card(
      child: ListTile(
        key: ValueKey('workout-${workout.id}'),
        leading: const Icon(Icons.fitness_center),
        title: Text(DateFormat('EEE, d MMM yyyy').format(workout.date)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$exerciseCount ${exerciseCount == 1 ? 'exercise' : 'exercises'}'
              ' · $setCount ${setCount == 1 ? 'set' : 'sets'}',
            ),
            Text(exercisePreview, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => widget.onOpenWorkout(workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredWorkouts = _filteredWorkouts;
    final groupedWorkouts = _groupByMonth(filteredWorkouts);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('start-workout'),
            onPressed: widget.onCreateWorkout,
            icon: const Icon(Icons.add),
            label: const Text('Start workout'),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Workout history',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('workout-history-search'),
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search exercises',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                  ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              key: const ValueKey('workout-history-date-filter'),
              onPressed: _chooseDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(_dateRangeLabel()),
            ),
            if (_dateRange != null)
              TextButton(
                key: const ValueKey('clear-workout-history-date-filter'),
                onPressed: () => setState(() => _dateRange = null),
                child: const Text('Clear dates'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.workouts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Your saved workouts will appear here.'),
            ),
          )
        else if (filteredWorkouts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('No workouts match these filters.'),
                  if (_dateRange != null || _searchController.text.isNotEmpty)
                    TextButton(
                      key: const ValueKey('clear-workout-history-filters'),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _dateRange = null);
                      },
                      child: const Text('Clear filters'),
                    ),
                ],
              ),
            ),
          )
        else
          ...groupedWorkouts.entries.expand(
            (entry) => [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  DateFormat('MMMM yyyy').format(entry.key),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ...entry.value.map(_buildWorkoutCard),
            ],
          ),
      ],
    );
  }
}
