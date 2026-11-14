import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'core/storage/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.initialize();
  runApp(const MyFitnessApp());
}

const teal = Color(0xFF20B8A9);
const background = Color(0xFF181C20);
const surface = Color(0xFF262B30);

class MyFitnessApp extends StatelessWidget {
  const MyFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myfitness Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const JournalHome(),
    );
  }
}

class JournalHome extends StatefulWidget {
  const JournalHome({super.key});

  @override
  State<JournalHome> createState() => _JournalHomeState();
}

class _JournalHomeState extends State<JournalHome> {
  int selectedTab = 0;
  DateTime selectedDate = DateTime.now();
  final Map<String, List<String>> workouts = {};
  final Map<String, double> weights = {};

  String get dateKey => DateFormat('yyyy-MM-dd').format(selectedDate);

  List<String> get selectedWorkout =>
      workouts.putIfAbsent(dateKey, () => <String>[]);

  void moveDate(int days) {
    setState(() => selectedDate = selectedDate.add(Duration(days: days)));
  }

  void addExercise() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add exercise'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Incline dumbbell press',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final exercise = controller.text.trim();
              if (exercise.isNotEmpty) {
                setState(() => selectedWorkout.add(exercise));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget card(Widget child) => Card(
        color: surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      );

  Widget homePage() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          card(const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Your fitness journey starts here.'),
            ],
          )),
          card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${selectedWorkout.length} exercises logged'),
              Text(weights[dateKey] == null
                  ? 'Weight not recorded'
                  : '${weights[dateKey]} kg'),
            ],
          )),
        ],
      );

  Widget workoutPage() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          card(Row(
            children: [
              Expanded(
                child: Text(DateFormat('EEE, d MMM').format(selectedDate)),
              ),
              IconButton(
                onPressed: addExercise,
                icon: const Icon(Icons.add_circle, color: teal),
              ),
            ],
          )),
          ...selectedWorkout.map((exercise) => card(Row(
                children: [
                  const Icon(Icons.fitness_center, color: teal),
                  const SizedBox(width: 12),
                  Expanded(child: Text(exercise)),
                  IconButton(
                    onPressed: () =>
                        setState(() => selectedWorkout.remove(exercise)),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ))),
          FilledButton.icon(
            onPressed: addExercise,
            icon: const Icon(Icons.add),
            label: const Text('Add exercise'),
          ),
        ],
      );

  Widget mealsPage() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          card(const Text('Nutrition tracking is coming next.',
              style: TextStyle(fontSize: 16))),
        ],
      );

  Widget weightPage() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily weight (kg)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                key: ValueKey(dateKey),
                initialValue: weights[dateKey]?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g. 73.2'),
                onChanged: (value) {
                  weights[dateKey] = double.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() => weights[dateKey] = weights[dateKey] ?? 0);
                },
                child: const Text('Save weight'),
              ),
            ],
          )),
          card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weight history',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...weights.entries.map((entry) => ListTile(
                    title: Text(entry.key),
                    trailing: Text('${entry.value} kg'),
                  )),
            ],
          )),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final pages = [homePage(), workoutPage(), mealsPage(), weightPage()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Myfitness Journal',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => moveDate(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: () => moveDate(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
              style: const TextStyle(color: teal),
            ),
          ),
          Expanded(child: pages[selectedTab]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) => setState(() => selectedTab = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Workout'),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Meals'),
          NavigationDestination(
              icon: Icon(Icons.monitor_weight), label: 'Weight'),
        ],
      ),
    );
  }
}
