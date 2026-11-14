import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/workout.dart';

/// Shows compact summaries derived from saved workouts and the selected date.
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.workouts,
    required this.selectedDate,
    required this.isLoading,
    required this.hasLoadError,
    required this.onOpenWorkout,
    required this.onOpenWeight,
    this.selectedDateWeight,
    super.key,
  });

  final List<Workout> workouts;
  final DateTime selectedDate;
  final bool isLoading;
  final bool hasLoadError;
  final double? selectedDateWeight;
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenWeight;

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int _workoutsForSelectedDate() => workouts
      .where((workout) => DateUtils.isSameDay(workout.date, selectedDate))
      .length;

  int _exercisesForSelectedDate() => workouts
      .where((workout) => DateUtils.isSameDay(workout.date, selectedDate))
      .fold(0, (total, workout) => total + workout.exercises.length);

  int _workoutsThisWeek() {
    final today = _dateOnly(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    return workouts.where((workout) {
      final date = _dateOnly(workout.date);
      return !date.isBefore(monday) && date.isBefore(nextMonday);
    }).length;
  }

  List<Workout> _recentWorkouts() {
    final sorted = List<Workout>.of(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(3).toList();
  }

  Widget _card(Widget child) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    final selectedDayTitle = isToday
        ? 'Today'
        : DateFormat('EEE, d MMM').format(selectedDate);
    final recent = _recentWorkouts();
    final sessionCount = _workoutsForSelectedDate();
    final exerciseCount = _exercisesForSelectedDate();

    return ListView(
      key: const ValueKey('dashboard-list'),
      padding: const EdgeInsets.all(12),
      children: [
        _card(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Your fitness journey starts here.'),
            ],
          ),
        ),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$selectedDayTitle summary',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Loading workout activity…'),
                  ],
                )
              else if (hasLoadError)
                const Text('Workout activity could not be loaded.')
              else if (sessionCount == 0)
                const Text('No workouts logged for this day.')
              else ...[
                Text(
                  '$sessionCount workout '
                  '${sessionCount == 1 ? 'session' : 'sessions'}',
                ),
                Text(
                  '$exerciseCount '
                  '${exerciseCount == 1 ? 'exercise' : 'exercises'} logged',
                ),
              ],
              if (selectedDateWeight != null) ...[
                const SizedBox(height: 4),
                Text('Weight: $selectedDateWeight kg'),
              ],
            ],
          ),
        ),
        _card(
          Row(
            children: [
              const Icon(Icons.calendar_view_week),
              const SizedBox(width: 12),
              const Expanded(child: Text('Workouts this week')),
              Text(
                isLoading || hasLoadError ? '—' : '${_workoutsThisWeek()}',
                key: const ValueKey('dashboard-weekly-count'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent workouts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    key: const ValueKey('dashboard-view-history'),
                    onPressed: onOpenWorkout,
                    child: const Text('View history'),
                  ),
                ],
              ),
              if (isLoading)
                const Text('Loading recent activity…')
              else if (hasLoadError)
                const Text('Recent workouts are unavailable.')
              else if (recent.isEmpty)
                const Text('Your saved workouts will appear here.')
              else
                ...recent.map(
                  (workout) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      DateFormat('EEE, d MMM yyyy').format(workout.date),
                    ),
                    subtitle: Text(
                      '${workout.exercises.length} '
                      '${workout.exercises.length == 1 ? 'exercise' : 'exercises'}',
                    ),
                  ),
                ),
            ],
          ),
        ),
        _card(
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('dashboard-open-workout'),
                  onPressed: onOpenWorkout,
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Workout'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('dashboard-open-weight'),
                  onPressed: onOpenWeight,
                  icon: const Icon(Icons.monitor_weight_outlined),
                  label: const Text('Weight'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
