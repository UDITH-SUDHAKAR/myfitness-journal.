import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/personal_record.dart';
import '../../core/storage/workout_repository.dart';
import 'personal_record_calculator.dart';

/// Displays all-time exercise records calculated from saved workouts.
class PersonalRecordsPage extends StatefulWidget {
  /// Creates the records page using saved workout history.
  const PersonalRecordsPage({required this.repository, super.key});

  /// Loads the workout data used to calculate records.
  final WorkoutRepository repository;

  @override
  State<PersonalRecordsPage> createState() => _PersonalRecordsPageState();
}

class _PersonalRecordsPageState extends State<PersonalRecordsPage> {
  List<ExercisePersonalRecords> _records = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final workouts = await widget.repository.getAll();
      final records = PersonalRecordCalculator.calculate(workouts);
      if (!mounted) return;
      setState(() {
        _records = records;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  String _weight(double weight) => weight == weight.roundToDouble()
      ? weight.toInt().toString()
      : weight.toString();

  Widget _buildRecordLine({
    required String label,
    required PersonalRecordMark record,
    required bool showRepsFirst,
  }) {
    final value = showRepsFirst
        ? '${record.reps} reps at ${_weight(record.weight)} kg'
        : '${_weight(record.weight)} kg × ${record.reps} reps';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                Text(value),
                Text(
                  DateFormat('d MMM yyyy').format(record.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(ExercisePersonalRecords records) => Card(
    key: ValueKey(
      'personal-record-${records.libraryExerciseId ?? PersonalRecordCalculator.normalizeName(records.name)}',
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(records.name, style: Theme.of(context).textTheme.titleMedium),
          if (records.heaviestSet != null)
            _buildRecordLine(
              label: 'Heaviest set',
              record: records.heaviestSet!,
              showRepsFirst: false,
            ),
          if (records.mostReps != null)
            _buildRecordLine(
              label: 'Most reps',
              record: records.mostReps!,
              showRepsFirst: true,
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Records')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load personal records.'),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadRecords,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          : _records.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Log completed sets to start building records.'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Text('Your best saved sets for each exercise.'),
                const SizedBox(height: 8),
                ..._records.map(_buildRecordCard),
              ],
            ),
    );
  }
}
