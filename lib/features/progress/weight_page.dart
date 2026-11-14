import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/body_weight_entry.dart';
import '../../core/storage/body_weight_repository.dart';

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
  String? _error;

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
    try {
      final entries = await widget.repository.getAll();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
        _error = null;
      });
      _setValueForSelectedDate();
      widget.onEntriesChanged(List.unmodifiable(entries));
      widget.onLoadFinished(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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
