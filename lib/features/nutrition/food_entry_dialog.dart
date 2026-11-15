import 'package:flutter/material.dart';

import '../../core/models/food.dart';

/// Collects the serving information and nutrition values for a reusable food.
class FoodEntryDialog extends StatefulWidget {
  const FoodEntryDialog({super.key});

  @override
  State<FoodEntryDialog> createState() => _FoodEntryDialogState();
}

class _FoodEntryDialogState extends State<FoodEntryDialog> {
  final _name = TextEditingController();
  final _servingSize = TextEditingController(text: '100');
  final _servingUnit = TextEditingController(text: 'g');
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fats = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _servingSize.dispose();
    _servingUnit.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fats.dispose();
    super.dispose();
  }

  void _save() {
    final food = Food(
      name: _name.text.trim(),
      servingSize: double.tryParse(_servingSize.text.trim()) ?? double.nan,
      servingUnit: _servingUnit.text.trim(),
      caloriesPerServing: double.tryParse(_calories.text.trim()) ?? double.nan,
      proteinGramsPerServing:
          double.tryParse(_protein.text.trim()) ?? double.nan,
      carbsGramsPerServing: double.tryParse(_carbs.text.trim()) ?? double.nan,
      fatGramsPerServing: double.tryParse(_fats.text.trim()) ?? double.nan,
    );
    try {
      food.validate();
      Navigator.of(context).pop(food);
    } on ArgumentError catch (error) {
      setState(() => _error = error.message.toString());
    }
  }

  Widget _numberField(
    String key,
    String label,
    TextEditingController controller, {
    bool decimal = true,
  }) => TextField(
    key: ValueKey(key),
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    decoration: InputDecoration(labelText: label),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add food to library'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const ValueKey('food-name-field'),
            controller: _name,
            decoration: const InputDecoration(labelText: 'Food name'),
          ),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  'food-serving-size-field',
                  'Serving size',
                  _servingSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: const ValueKey('food-serving-unit-field'),
                  controller: _servingUnit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
              ),
            ],
          ),
          _numberField('food-calories-field', 'Calories (kcal)', _calories),
          _numberField('food-protein-field', 'Protein (g)', _protein),
          _numberField('food-carbs-field', 'Carbs (g)', _carbs),
          _numberField('food-fats-field', 'Fats (g)', _fats),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, key: const ValueKey('food-form-error')),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const ValueKey('save-food-definition'),
        onPressed: _save,
        child: const Text('Save food'),
      ),
    ],
  );
}
