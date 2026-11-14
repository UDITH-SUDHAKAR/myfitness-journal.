import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/workout.dart';
import '../../core/storage/workout_repository.dart';
import 'workout_progress_calculator.dart';

enum _ProgressPeriod { weekly, monthly }

enum _ChartMetric { sessions, volume }

/// Displays saved workout frequency, training volume, and exercise summaries.
class WorkoutStatisticsPage extends StatefulWidget {
  const WorkoutStatisticsPage({required this.repository, super.key});

  final WorkoutRepository repository;

  @override
  State<WorkoutStatisticsPage> createState() => _WorkoutStatisticsPageState();
}

class _WorkoutStatisticsPageState extends State<WorkoutStatisticsPage> {
  List<Workout> _workouts = [];
  bool _isLoading = true;
  String? _error;
  _ProgressPeriod _period = _ProgressPeriod.weekly;
  _ChartMetric _metric = _ChartMetric.sessions;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final workouts = await widget.repository.getAll();
      if (!mounted) return;
      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  List<WorkoutPeriodSummary> get _periods => _period == _ProgressPeriod.weekly
      ? WorkoutProgressCalculator.weeklyProgress(
          workouts: _workouts,
          referenceDate: DateTime.now(),
        )
      : WorkoutProgressCalculator.monthlyProgress(
          workouts: _workouts,
          referenceDate: DateTime.now(),
        );

  List<ExerciseWorkoutStatistics> get _exerciseStats =>
      WorkoutProgressCalculator.exerciseStatistics(_workouts)..sort((a, b) {
        final bySessions = b.sessionCount.compareTo(a.sessionCount);
        return bySessions != 0
            ? bySessions
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

  Widget _buildChart() {
    final periods = _periods;
    final values = periods
        .map(
          (summary) => _metric == _ChartMetric.sessions
              ? summary.workoutCount.toDouble()
              : summary.volumeKg,
        )
        .toList();
    final largestValue = values.fold<double>(
      0,
      (largest, value) => math.max(largest, value).toDouble(),
    );
    final maxY = largestValue == 0 ? 1.0 : largestValue * 1.15;

    return SizedBox(
      key: const ValueKey('workout-progress-chart'),
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          barGroups: List<BarChartGroupData>.generate(
            periods.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  color: Theme.of(context).colorScheme.primary,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= periods.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % 2 != 0 && index != periods.length - 1) {
                    return const SizedBox.shrink();
                  }
                  final date = periods[index].startDate;
                  final label = _period == _ProgressPeriod.weekly
                      ? DateFormat('d MMM').format(date)
                      : DateFormat('MMM yy').format(date);
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final amount = _metric == _ChartMetric.sessions
                    ? '${rod.toY.toInt()} sessions'
                    : '${rod.toY.toStringAsFixed(0)} kg×reps';
                return BarTooltipItem(
                  amount,
                  TextStyle(color: Theme.of(context).colorScheme.onSurface),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load workout statistics.'),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
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
    if (_workouts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Save a workout to start building your statistics.'),
        ),
      );
    }

    final periods = _periods;
    final exercises = _exerciseStats;
    final totalVolume = exercises.fold<double>(
      0,
      (sum, exercise) => sum + exercise.volumeKg,
    );
    final allTimeWorkoutCount = _workouts.length;

    return ListView(
      key: const ValueKey('workout-statistics-list'),
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _summaryValue(
                    label: 'Saved workouts',
                    value: '$allTimeWorkoutCount',
                  ),
                ),
                Expanded(
                  child: _summaryValue(
                    label: 'All-time volume',
                    value: '${totalVolume.toStringAsFixed(0)} kg×reps',
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SegmentedButton<_ProgressPeriod>(
                  key: const ValueKey('workout-progress-period-selector'),
                  segments: const [
                    ButtonSegment(
                      value: _ProgressPeriod.weekly,
                      label: Text('12 weeks'),
                    ),
                    ButtonSegment(
                      value: _ProgressPeriod.monthly,
                      label: Text('12 months'),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (selection) =>
                      setState(() => _period = selection.first),
                ),
                const SizedBox(height: 8),
                SegmentedButton<_ChartMetric>(
                  key: const ValueKey('workout-progress-metric-selector'),
                  segments: const [
                    ButtonSegment(
                      value: _ChartMetric.sessions,
                      label: Text('Sessions'),
                    ),
                    ButtonSegment(
                      value: _ChartMetric.volume,
                      label: Text('Volume'),
                    ),
                  ],
                  selected: {_metric},
                  onSelectionChanged: (selection) =>
                      setState(() => _metric = selection.first),
                ),
                const SizedBox(height: 8),
                Text(
                  _period == _ProgressPeriod.weekly
                      ? 'Last 12 weeks'
                      : 'Last 12 months',
                  key: const ValueKey('workout-progress-range-label'),
                ),
                const SizedBox(height: 16),
                _buildChart(),
                const SizedBox(height: 4),
                Text(
                  _metric == _ChartMetric.sessions
                      ? 'Saved workout sessions per period'
                      : 'External-load volume (kg × reps) per period',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  '${periods.last.workoutCount} workouts in the '
                  '${_period == _ProgressPeriod.weekly ? 'current week' : 'current month'}',
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercise statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (exercises.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'No exercises have been added to saved workouts.',
                    ),
                  )
                else
                  ...exercises.map(
                    (exercise) => ListTile(
                      key: ValueKey(
                        'exercise-stat-${exercise.libraryExerciseId ?? exercise.name.toLowerCase()}',
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.sessionCount} '
                        '${exercise.sessionCount == 1 ? 'session' : 'sessions'} · '
                        '${exercise.setCount} '
                        '${exercise.setCount == 1 ? 'set' : 'sets'} · '
                        '${exercise.repCount} reps',
                      ),
                      trailing: Text(
                        '${exercise.volumeKg.toStringAsFixed(0)} kg×reps',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryValue({required String label, required String value}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Statistics'),
        actions: [
          IconButton(
            key: const ValueKey('refresh-workout-statistics'),
            tooltip: 'Refresh statistics',
            onPressed: _isLoading ? null : _loadWorkouts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
}
