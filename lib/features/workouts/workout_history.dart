import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/workout.dart';

/// A simple list of saved workouts. Tapping a workout opens its details.
class WorkoutHistory extends StatelessWidget {
  /// Creates a workout history list.
  const WorkoutHistory({
    required this.workouts,
    required this.onOpenWorkout,
    required this.onCreateWorkout,
    super.key,
  });

  /// Workouts to show, usually sorted from newest to oldest.
  final List<Workout> workouts;

  /// Opens a workout selected from the history.
  final ValueChanged<Workout> onOpenWorkout;

  /// Starts a new workout.
  final VoidCallback onCreateWorkout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('start-workout'),
            onPressed: onCreateWorkout,
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
        if (workouts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Your saved workouts will appear here.'),
            ),
          )
        else
          ...workouts.map(
            (workout) => Card(
              child: ListTile(
                key: ValueKey('workout-${workout.id}'),
                leading: const Icon(Icons.fitness_center),
                title: Text(DateFormat('EEE, d MMM yyyy').format(workout.date)),
                subtitle: Text(
                  '${workout.exercises.length} '
                  '${workout.exercises.length == 1 ? 'exercise' : 'exercises'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onOpenWorkout(workout),
              ),
            ),
          ),
      ],
    );
  }
}
