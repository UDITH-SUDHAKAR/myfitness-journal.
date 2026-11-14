import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'core/models/workout.dart';
import 'core/storage/isar_service.dart';
import 'core/storage/isar_workout_repository.dart';
import 'core/storage/workout_repository.dart';
import 'core/storage/exercise_library_repository.dart';
import 'core/storage/isar_exercise_library_repository.dart';
import 'features/workouts/workout_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.initialize();
  runApp(
    MyFitnessApp(
      workoutRepository: IsarWorkoutRepository(IsarService.instance.database),
      exerciseLibraryRepository: IsarExerciseLibraryRepository(
        IsarService.instance.database,
      ),
    ),
  );
}

const teal = Color(0xFF20B8A9);
const background = Color(0xFF181C20);
const surface = Color(0xFF262B30);

class MyFitnessApp extends StatelessWidget {
  const MyFitnessApp({
    required this.workoutRepository,
    required this.exerciseLibraryRepository,
    super.key,
  });

  /// Repository shared by the workout UI.
  final WorkoutRepository workoutRepository;

  /// Repository shared by the exercise library and workout editor.
  final ExerciseLibraryRepository exerciseLibraryRepository;

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
      home: JournalHome(
        workoutRepository: workoutRepository,
        exerciseLibraryRepository: exerciseLibraryRepository,
      ),
    );
  }
}

class JournalHome extends StatefulWidget {
  const JournalHome({
    required this.workoutRepository,
    required this.exerciseLibraryRepository,
    super.key,
  });

  /// Provides saved workout data to the workout tab.
  final WorkoutRepository workoutRepository;

  /// Provides local exercise library data.
  final ExerciseLibraryRepository exerciseLibraryRepository;

  @override
  State<JournalHome> createState() => _JournalHomeState();
}

class _JournalHomeState extends State<JournalHome> {
  int selectedTab = 0;
  DateTime selectedDate = DateTime.now();
  final Map<String, double> weights = {};
  List<Workout> savedWorkouts = [];

  void _workoutsChanged(List<Workout> workouts) {
    setState(() => savedWorkouts = workouts);
  }

  String get dateKey => DateFormat('yyyy-MM-dd').format(selectedDate);

  void moveDate(int days) {
    setState(() => selectedDate = selectedDate.add(Duration(days: days)));
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Widget card(Widget child) => Card(
    color: surface,
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget homePage() => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      card(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Your fitness journey starts here.'),
          ],
        ),
      ),
      card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('$exerciseCountForSelectedDate exercises logged'),
            Text(
              weights[dateKey] == null
                  ? 'Weight not recorded'
                  : '${weights[dateKey]} kg',
            ),
          ],
        ),
      ),
    ],
  );

  int get exerciseCountForSelectedDate => savedWorkouts
      .where((workout) => DateUtils.isSameDay(workout.date, selectedDate))
      .fold(0, (total, workout) => total + workout.exercises.length);

  Widget mealsPage() => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      card(
        const Text(
          'Nutrition tracking is coming next.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    ],
  );

  Widget weightPage() => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily weight (kg)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
        ),
      ),
      card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weight history',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...weights.entries.map(
              (entry) => ListTile(
                title: Text(entry.key),
                trailing: Text('${entry.value} kg'),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      homePage(),
      WorkoutPage(
        repository: widget.workoutRepository,
        exerciseLibraryRepository: widget.exerciseLibraryRepository,
        selectedDate: selectedDate,
        onWorkoutsChanged: _workoutsChanged,
      ),
      mealsPage(),
      weightPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Myfitness Journal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          InkWell(
            onTap: selectDate,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                    style: const TextStyle(color: teal),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.calendar_month, size: 18, color: teal),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(index: selectedTab, children: pages),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) => setState(() => selectedTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Meals'),
          NavigationDestination(
            icon: Icon(Icons.monitor_weight),
            label: 'Weight',
          ),
        ],
      ),
    );
  }
}
