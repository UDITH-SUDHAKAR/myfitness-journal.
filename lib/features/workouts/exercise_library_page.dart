import 'package:flutter/material.dart';

import '../../core/models/exercise_library_item.dart';
import '../../core/storage/exercise_library_repository.dart';

/// Lists and manages reusable exercises stored on this device.
class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({required this.repository, super.key});

  final ExerciseLibraryRepository repository;

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final _searchController = TextEditingController();
  List<ExerciseLibraryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await widget.repository.search(_searchController.text);
    if (mounted) setState(() => _items = items);
  }

  Future<void> _edit([ExerciseLibraryItem? existing]) async {
    final result = await showDialog<ExerciseLibraryItem>(
      context: context,
      builder: (_) => _ExerciseForm(item: existing),
    );
    if (result == null) return;
    if (existing == null) {
      await widget.repository.save(result);
    } else {
      result.id = existing.id;
      await widget.repository.update(result);
    }
    await _load();
  }

  Future<void> _delete(ExerciseLibraryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete exercise?'),
        content: Text('Delete ${item.name} from the library?'),
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
    if (confirmed == true) {
      await widget.repository.delete(item.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Exercise library')),
    floatingActionButton: FloatingActionButton.extended(
      key: const ValueKey('add-library-exercise'),
      onPressed: () => _edit(),
      icon: const Icon(Icons.add),
      label: const Text('Add exercise'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            key: const ValueKey('library-search'),
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search exercises',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => _load(),
          ),
        ),
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text('No exercises found.'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.muscleGroup} • ${item.equipment}'),
                      onTap: () => _edit(item),
                      trailing: IconButton(
                        tooltip: 'Delete ${item.name}',
                        onPressed: () => _delete(item),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}

class _ExerciseForm extends StatefulWidget {
  const _ExerciseForm({this.item});
  final ExerciseLibraryItem? item;

  @override
  State<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<_ExerciseForm> {
  static const muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Legs',
    'Core',
    'Cardio',
  ];
  static const equipmentTypes = [
    'Barbell',
    'Dumbbell',
    'Machine',
    'Cable',
    'Bodyweight',
    'Other',
  ];
  late final _name = TextEditingController(text: widget.item?.name);
  late final _description = TextEditingController(
    text: widget.item?.description,
  );
  late String _muscleGroup = widget.item?.muscleGroup ?? muscleGroups.first;
  late String _equipment = widget.item?.equipment ?? equipmentTypes.first;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item == null ? 'Add exercise' : 'Edit exercise'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const ValueKey('library-exercise-name'),
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          DropdownButtonFormField<String>(
            initialValue:
                [
                  ...muscleGroups,
                  'Other',
                  if (_muscleGroup != 'Other' &&
                      !muscleGroups.contains(_muscleGroup))
                    _muscleGroup,
                ].contains(_muscleGroup)
                ? _muscleGroup
                : 'Other',
            items:
                [
                      ...muscleGroups,
                      'Other',
                      if (_muscleGroup != 'Other' &&
                          !muscleGroups.contains(_muscleGroup))
                        _muscleGroup,
                    ]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _muscleGroup = value!),
            decoration: const InputDecoration(labelText: 'Muscle group'),
          ),
          DropdownButtonFormField<String>(
            initialValue:
                [
                  ...equipmentTypes,
                  if (!equipmentTypes.contains(_equipment)) _equipment,
                ].contains(_equipment)
                ? _equipment
                : 'Other',
            items:
                [
                      ...equipmentTypes,
                      if (!equipmentTypes.contains(_equipment)) _equipment,
                    ]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _equipment = value!),
            decoration: const InputDecoration(labelText: 'Equipment'),
          ),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Instructions (optional)',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final name = _name.text.trim();
          if (name.isEmpty) return;
          Navigator.pop(
            context,
            ExerciseLibraryItem(
              id: widget.item?.id ?? -1,
              name: name,
              muscleGroup: _muscleGroup,
              equipment: _equipment,
              description: _description.text.trim().isEmpty
                  ? null
                  : _description.text.trim(),
            ),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}
