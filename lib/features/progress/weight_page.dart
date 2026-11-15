import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/body_weight_entry.dart';
import '../../core/storage/body_weight_repository.dart';
import 'body_weight_progress_calculator.dart';

/// Records daily body weight and shows the saved measurements.
class WeightPage extends StatefulWidget {
  const WeightPage({
    required this.repository,
    required this.selectedDate,
    required this.onEntriesChanged,
    required this.onLoadFinished,
    super.key,
  });

  final BodyWeightRepository repository;
  final DateTime selectedDate;
  final ValueChanged<List<BodyWeightEntry>> onEntriesChanged;
  final ValueChanged<bool> onLoadFinished;

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final _weightController = TextEditingController();
  List<BodyWeightEntry> _entries = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String? _error;
  BodyWeightProgressPeriod _progressPeriod = BodyWeightProgressPeriod.weeks;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void didUpdateWidget(covariant WeightPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateUtils.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _setValueForSelectedDate();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });
    try {
      final entries = await widget.repository.getAll();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
        _hasLoadError = false;
        _error = null;
      });
      _setValueForSelectedDate();
      widget.onEntriesChanged(List.unmodifiable(entries));
      widget.onLoadFinished(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasLoadError = true;
        _error = error.toString();
      });
      widget.onLoadFinished(false);
    }
  }

  void _setValueForSelectedDate() {
    final entry = _entryForDate(widget.selectedDate);
    _weightController.text = entry?.weightKg.toString() ?? '';
  }

  BodyWeightEntry? _entryForDate(DateTime date) {
    for (final entry in _entries) {
      if (DateUtils.isSameDay(entry.date, date)) return entry;
    }
    return null;
  }

  Future<void> _saveWeight() async {
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || !weight.isFinite || weight <= 0) {
      setState(() => _error = 'Enter a weight greater than 0 kg.');
      return;
    }
    try {
      await widget.repository.save(
        BodyWeightEntry(
          date: DateUtils.dateOnly(widget.selectedDate),
          weightKg: weight,
        ),
      );
      await _loadEntries();
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not save weight: $error');
    }
  }

  Future<void> _editEntry(BodyWeightEntry entry) async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) =>
          _WeightEditDialog(date: entry.date, initialWeight: entry.weightKg),
    );
    if (value == null) return;
    if (!value.isFinite || value <= 0) {
      setState(() => _error = 'Enter a weight greater than 0 kg.');
      return;
    }
    try {
      final updated = BodyWeightEntry(
        id: entry.id,
        date: entry.date,
        weightKg: value,
      );
      if (!await widget.repository.update(updated)) {
        throw StateError('This weight entry could not be found.');
      }
      await _loadEntries();
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not update weight: $error');
    }
  }

  Future<void> _deleteEntry(BodyWeightEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete weight entry?'),
        content: Text(
          'Remove the ${entry.weightKg} kg entry for '
          '${DateFormat('d MMM yyyy').format(entry.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    try {
      await widget.repository.delete(entry.id);
      await _loadEntries();
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not delete weight: $error');
    }
  }

  BodyWeightProgress get _progress =>
      _progressPeriod == BodyWeightProgressPeriod.weeks
      ? BodyWeightProgressCalculator.forWeeks(
          entries: _entries,
          referenceDate: DateTime.now(),
        )
      : BodyWeightProgressCalculator.forMonths(
          entries: _entries,
          referenceDate: DateTime.now(),
        );

  String get _progressPeriodLabel =>
      _progressPeriod == BodyWeightProgressPeriod.weeks
      ? '12 weeks'
      : '12 months';

  Widget _buildProgressChart(BuildContext context) {
    if (_isLoading) {
      return const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
          Text('Loading weight progress...'),
        ],
      );
    }
    if (_hasLoadError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Could not load weight progress.'),
          TextButton(onPressed: _loadEntries, child: const Text('Try again')),
        ],
      );
    }
    if (_entries.isEmpty) {
      return const Text('Record weight to start building your progress chart.');
    }

    final progress = _progress;
    if (progress.entries.isEmpty) {
      return Text('No weight entries in the last $_progressPeriodLabel.');
    }

    final chartEntries = progress.entries;
    final firstOrdinal = DateTime.utc(
      progress.startDate.year,
      progress.startDate.month,
      progress.startDate.day,
    );
    final spots = chartEntries.map((entry) {
      final entryOrdinal = DateTime.utc(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return FlSpot(
        entryOrdinal.difference(firstOrdinal).inDays.toDouble(),
        entry.weightKg,
      );
    }).toList();
    final chartSegments = _segmentsForMeasurements(spots);
    final weights = chartEntries.map((entry) => entry.weightKg);
    final minWeight = weights.reduce(math.min).toDouble();
    final maxWeight = weights.reduce(math.max).toDouble();
    final yPadding = math.max((maxWeight - minWeight) * 0.15, 0.5).toDouble();
    final firstDay = DateTime.utc(
      progress.startDate.year,
      progress.startDate.month,
      progress.startDate.day,
    );
    final endDay = DateTime.utc(
      progress.endDate.year,
      progress.endDate.month,
      progress.endDate.day,
    );
    final maxX = math.max(1, endDay.difference(firstDay).inDays).toDouble();
    final lineColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          key: const ValueKey('body-weight-progress-chart'),
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxX,
              minY: math.max(0, minWeight - yPadding),
              maxY: maxWeight + yPadding,
              lineBarsData: chartSegments
                  .map(
                    (segment) => LineChartBarData(
                      spots: segment.map((index) => spots[index]).toList(),
                      isCurved: false,
                      color: lineColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withValues(alpha: 0.12),
                      ),
                    ),
                  )
                  .toList(),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _progressPeriod == BodyWeightProgressPeriod.weeks
                        ? 14
                        : 60,
                    getTitlesWidget: (value, meta) {
                      final date = progress.startDate.add(
                        Duration(days: value.round()),
                      );
                      final label =
                          _progressPeriod == BodyWeightProgressPeriod.weeks
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
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                    final entryIndex =
                        chartSegments[spot.barIndex][spot.spotIndex];
                    final entry = chartEntries[entryIndex];
                    return LineTooltipItem(
                      '${DateFormat('d MMM yyyy').format(entry.date)}\n'
                      '${entry.weightKg.toStringAsFixed(1)} kg',
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Only recorded measurements are plotted. Gaps longer than '
          '${_progressPeriod == BodyWeightProgressPeriod.weeks ? '14' : '45'} '
          'days are not connected.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        _buildProgressSummary(progress),
      ],
    );
  }

  /// Splits long gaps so the chart does not imply a continuous trend where
  /// there has been no recent measurement.
  List<List<int>> _segmentsForMeasurements(List<FlSpot> spots) {
    final gapLimit = _progressPeriod == BodyWeightProgressPeriod.weeks
        ? 14
        : 45;
    final segments = <List<int>>[
      [0],
    ];
    for (var index = 1; index < spots.length; index++) {
      final daysSincePrevious = spots[index].x - spots[index - 1].x;
      if (daysSincePrevious > gapLimit) {
        segments.add([index]);
      } else {
        segments.last.add(index);
      }
    }
    return segments;
  }

  Widget _buildProgressSummary(BodyWeightProgress progress) {
    final first = progress.firstEntry!;
    final latest = progress.latestEntry!;
    final change = progress.absoluteChangeKg;
    final changeText = change == null
        ? 'Not enough entries to show a change'
        : change == 0
        ? 'Absolute change: 0 kg (no change)'
        : 'Absolute change: ${change.toStringAsFixed(1)} kg '
              '(${progress.increased ? 'increase' : 'decrease'})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First: ${first.weightKg.toStringAsFixed(1)} kg · '
          '${DateFormat('d MMM yyyy').format(first.date)}',
          key: const ValueKey('body-weight-first-summary'),
        ),
        Text(
          'Latest: ${latest.weightKg.toStringAsFixed(1)} kg · '
          '${DateFormat('d MMM yyyy').format(latest.date)}',
          key: const ValueKey('body-weight-latest-summary'),
        ),
        Text(changeText, key: const ValueKey('body-weight-change-summary')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weight progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<BodyWeightProgressPeriod>(
                  key: const ValueKey('body-weight-period-selector'),
                  segments: const [
                    ButtonSegment(
                      value: BodyWeightProgressPeriod.weeks,
                      label: Text('12 weeks'),
                    ),
                    ButtonSegment(
                      value: BodyWeightProgressPeriod.months,
                      label: Text('12 months'),
                    ),
                  ],
                  selected: {_progressPeriod},
                  onSelectionChanged: (selection) =>
                      setState(() => _progressPeriod = selection.first),
                ),
                const SizedBox(height: 12),
                _buildProgressChart(context),
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
                  'Daily weight (kg)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  DateFormat('EEEE, d MMM yyyy').format(widget.selectedDate),
                ),
                TextField(
                  key: const ValueKey('weight-value-field'),
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: 'e.g. 73.2',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey('save-weight-entry'),
                  onPressed: _isLoading ? null : _saveWeight,
                  child: const Text('Save weight'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, key: const ValueKey('weight-error')),
                ],
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
                  'Weight history',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  TextButton(
                    onPressed: _loadEntries,
                    child: const Text('Try again'),
                  )
                else if (_entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'No weight entries yet. Record your first measurement above.',
                    ),
                  )
                else
                  ..._entries.map(
                    (entry) => ListTile(
                      key: ValueKey('weight-entry-${entry.id}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        DateFormat('EEE, d MMM yyyy').format(entry.date),
                      ),
                      subtitle: Text('${entry.weightKg} kg'),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Edit weight',
                            onPressed: () => _editEntry(entry),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete weight',
                            onPressed: () => _deleteEntry(entry),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
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
}

class _WeightEditDialog extends StatefulWidget {
  const _WeightEditDialog({required this.date, required this.initialWeight});

  final DateTime date;
  final double initialWeight;

  @override
  State<_WeightEditDialog> createState() => _WeightEditDialogState();
}

class _WeightEditDialogState extends State<_WeightEditDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialWeight.toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Edit ${DateFormat('d MMM yyyy').format(widget.date)}'),
    content: TextField(
      key: const ValueKey('weight-edit-field'),
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(labelText: 'Weight (kg)'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () =>
            Navigator.pop(context, double.tryParse(_controller.text.trim())),
        child: const Text('Save'),
      ),
    ],
  );
}
