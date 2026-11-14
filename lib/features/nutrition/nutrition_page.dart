import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/nutrition_entry.dart';
import '../../core/storage/nutrition_repository.dart';

/// Logs simple food entries and displays the selected day's nutrition totals.
class NutritionPage extends StatefulWidget {
  const NutritionPage({
    required this.repository,
    required this.selectedDate,
    required this.onEntriesChanged,
    required this.onLoadFinished,
    super.key,
  });

  final NutritionRepository repository;
  final DateTime selectedDate;
  final ValueChanged<List<NutritionEntry>> onEntriesChanged;
  final ValueChanged<bool> onLoadFinished;

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  List<NutritionEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
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

  List<NutritionEntry> get _entriesForSelectedDate => _entries.where((entry) {
    return entry.date.year == widget.selectedDate.year &&
        entry.date.month == widget.selectedDate.month &&
        entry.date.day == widget.selectedDate.day;
  }).toList();

  Future<void> _saveEntry() async {
    final name = _nameController.text.trim();
    final calories = int.tryParse(_caloriesController.text.trim());
    final protein = double.tryParse(_proteinController.text.trim());
    if (name.isEmpty ||
        calories == null ||
        calories < 0 ||
        protein == null ||
        !protein.isFinite ||
        protein < 0) {
      setState(
        () => _error = 'Enter a name and valid non-negative nutrition values.',
      );
      return;
    }
    try {
      await widget.repository.save(
        NutritionEntry(
          date: DateUtils.dateOnly(widget.selectedDate),
          name: name,
          calories: calories,
          proteinGrams: protein,
        ),
      );
      _nameController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      await _loadEntries();
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not save nutrition entry: $error');
      }
    }
  }

  Future<void> _deleteEntry(NutritionEntry entry) async {
    try {
      await widget.repository.delete(entry.id);
      await _loadEntries();
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not delete nutrition entry: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyEntries = _entriesForSelectedDate;
    final calories = dailyEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.calories,
    );
    final protein = dailyEntries.fold<double>(
      0,
      (sum, entry) => sum + entry.proteinGrams,
    );

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
                  'Nutrition · ${DateFormat('d MMM yyyy').format(widget.selectedDate)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null && _entries.isEmpty)
                  const Text('Nutrition entries could not be loaded.')
                else if (dailyEntries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('No nutrition entries logged for this day.'),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '$calories kcal · ${protein.toStringAsFixed(1)} g protein',
                      key: const ValueKey('daily-nutrition-total'),
                      style: Theme.of(context).textTheme.titleMedium,
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
                  'Add food or meal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextField(
                  key: const ValueKey('nutrition-name-field'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('nutrition-calories-field'),
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories (kcal)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const ValueKey('nutrition-protein-field'),
                        controller: _proteinController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey('save-nutrition-entry'),
                  onPressed: _isLoading ? null : _saveEntry,
                  child: const Text('Add entry'),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      key: const ValueKey('nutrition-error'),
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
                  'Entries for selected date',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null && _entries.isEmpty)
                  TextButton(
                    onPressed: _loadEntries,
                    child: const Text('Try again'),
                  )
                else if (dailyEntries.isEmpty)
                  const Text('Your logged food will appear here.')
                else
                  ...dailyEntries.map(
                    (entry) => ListTile(
                      key: ValueKey('nutrition-entry-${entry.id}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.name),
                      subtitle: Text(
                        '${entry.calories} kcal · ${entry.proteinGrams} g protein',
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete entry',
                        onPressed: () => _deleteEntry(entry),
                        icon: const Icon(Icons.delete_outline),
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
