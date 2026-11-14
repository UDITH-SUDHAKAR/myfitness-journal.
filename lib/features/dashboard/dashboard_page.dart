import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/workout.dart';
import '../../core/models/body_weight_entry.dart';
import '../../core/models/nutrition_entry.dart';
import 'body_weight_statistics.dart';
import 'nutrition_statistics.dart';
import 'workout_statistics.dart';

/// Shows compact summaries derived from saved workouts and the selected date.
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.workouts,
    required this.selectedDate,
    required this.isLoading,
    required this.hasLoadError,
    required this.bodyWeightEntries,
    required this.isBodyWeightLoading,
    required this.bodyWeightLoadError,
    required this.nutritionEntries,
    required this.isNutritionLoading,
    required this.nutritionLoadError,
    required this.onOpenWorkout,
    required this.onOpenStatistics,
    required this.onOpenMeals,
    required this.onOpenWeight,
    super.key,
  });

  final List<Workout> workouts;
  final DateTime selectedDate;
  final bool isLoading;
  final bool hasLoadError;
  final List<BodyWeightEntry> bodyWeightEntries;
  final bool isBodyWeightLoading;
  final bool bodyWeightLoadError;
  final List<NutritionEntry> nutritionEntries;
  final bool isNutritionLoading;
  final bool nutritionLoadError;
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenStatistics;
  final VoidCallback onOpenMeals;
  final VoidCallback onOpenWeight;

  int _workoutsForSelectedDate() => workouts
      .where((workout) => DateUtils.isSameDay(workout.date, selectedDate))
      .length;

  int _exercisesForSelectedDate() => workouts
      .where((workout) => DateUtils.isSameDay(workout.date, selectedDate))
      .fold(0, (total, workout) => total + workout.exercises.length);

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
    final statistics = WorkoutStatisticsCalculator.calculate(
      workouts: workouts,
      referenceDate: DateTime.now(),
    );
    final latestWeight = BodyWeightStatistics.latestEntry(bodyWeightEntries);
    final nutritionTotals = NutritionStatisticsCalculator.forDate(
      entries: nutritionEntries,
      date: selectedDate,
    );

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
                isLoading || hasLoadError
                    ? '—'
                    : '${statistics.weeklyWorkoutCount}',
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
              const Text(
                'Weekly activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const Text('Loading weekly activity…')
              else if (hasLoadError)
                const Text('Weekly activity could not be loaded.')
              else
                Row(
                  children: statistics.weeklyActivity.map((day) {
                    final dayLabel = DateFormat('E').format(day.date);
                    return Expanded(
                      child: Column(
                        children: [
                          Text('${day.count}'),
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: 6,
                            decoration: BoxDecoration(
                              color: day.count == 0
                                  ? Colors.white24
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayLabel,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              Text(
                'All time: ${isLoading || hasLoadError ? '—' : statistics.allTimeWorkoutCount} '
                '${!isLoading && !hasLoadError && statistics.allTimeWorkoutCount == 1 ? 'workout' : 'workouts'}',
                key: const ValueKey('dashboard-all-time-workout-count'),
              ),
            ],
          ),
        ),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Training summary this week',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                isLoading || hasLoadError
                    ? '—'
                    : '${statistics.weeklyExerciseCount} '
                          '${statistics.weeklyExerciseCount == 1 ? 'exercise' : 'exercises'} · '
                          '${statistics.weeklySetCount} sets · '
                          '${statistics.weeklyRepCount} reps',
                key: const ValueKey('dashboard-training-summary'),
              ),
            ],
          ),
        ),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latest body weight',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              if (isBodyWeightLoading)
                const Text('Loading weight history…')
              else if (bodyWeightLoadError)
                const Text('Weight history could not be loaded.')
              else if (latestWeight == null)
                const Text('No weight entries yet.')
              else
                Text(
                  '${latestWeight.weightKg} kg · '
                  '${DateFormat('d MMM yyyy').format(latestWeight.date)}',
                  key: const ValueKey('dashboard-latest-weight'),
                ),
            ],
          ),
        ),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nutrition for selected day',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              if (isNutritionLoading)
                const Text('Loading nutrition entries…')
              else if (nutritionLoadError)
                const Text('Nutrition entries could not be loaded.')
              else if (!nutritionEntries.any(
                (entry) => DateUtils.isSameDay(entry.date, selectedDate),
              ))
                const Text('No nutrition entries for this day.')
              else
                Text(
                  '${nutritionTotals.calories} kcal · '
                  '${nutritionTotals.proteinGrams.toStringAsFixed(1)} g protein',
                  key: const ValueKey('dashboard-daily-nutrition'),
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
                const Text(
                  'Your saved workouts will appear here.',
                  key: ValueKey('dashboard-empty-recent'),
                )
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('dashboard-open-workout'),
                onPressed: onOpenWorkout,
                icon: const Icon(Icons.fitness_center),
                label: const Text('Workout'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('dashboard-open-weight'),
                onPressed: onOpenWeight,
                icon: const Icon(Icons.monitor_weight_outlined),
                label: const Text('Weight'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('dashboard-open-meals'),
                onPressed: onOpenMeals,
                icon: const Icon(Icons.restaurant),
                label: const Text('Meals'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('dashboard-open-statistics'),
                onPressed: onOpenStatistics,
                icon: const Icon(Icons.query_stats),
                label: const Text('Statistics'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
