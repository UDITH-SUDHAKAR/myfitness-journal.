import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'core/models/workout.dart';
import 'core/models/body_weight_entry.dart';
import 'core/models/nutrition_entry.dart';
import 'core/storage/isar_service.dart';
import 'core/storage/isar_workout_repository.dart';
import 'core/storage/workout_repository.dart';
import 'core/storage/exercise_library_repository.dart';
import 'core/storage/isar_exercise_library_repository.dart';
import 'core/storage/body_weight_repository.dart';
import 'core/storage/isar_body_weight_repository.dart';
import 'core/storage/nutrition_repository.dart';
import 'core/storage/isar_nutrition_repository.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/nutrition/nutrition_page.dart';
import 'features/progress/weight_page.dart';
import 'features/workouts/workout_page.dart';
import 'features/workouts/workout_statistics_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.initialize();
  runApp(
    MyFitnessApp(
      workoutRepository: IsarWorkoutRepository(IsarService.instance.database),
      exerciseLibraryRepository: IsarExerciseLibraryRepository(
        IsarService.instance.database,
      ),
      bodyWeightRepository: IsarBodyWeightRepository(
        IsarService.instance.database,
      ),
      nutritionRepository: IsarNutritionRepository(
        IsarService.instance.database,
      ),
    ),
  );
}

const teal = Color(0xFF20B8A9);
const background = Color(0xFF181C20);

class MyFitnessApp extends StatelessWidget {
  const MyFitnessApp({
    required this.workoutRepository,
    required this.exerciseLibraryRepository,
    required this.bodyWeightRepository,
    required this.nutritionRepository,
    super.key,
  });

  /// Repository shared by the workout UI.
  final WorkoutRepository workoutRepository;

  /// Repository shared by the exercise library and workout editor.
  final ExerciseLibraryRepository exerciseLibraryRepository;

  /// Stores daily body-weight entries.
  final BodyWeightRepository bodyWeightRepository;

  /// Stores food and meal nutrition entries.
  final NutritionRepository nutritionRepository;

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
        bodyWeightRepository: bodyWeightRepository,
        nutritionRepository: nutritionRepository,
      ),
    );
  }
}

class JournalHome extends StatefulWidget {
  const JournalHome({
    required this.workoutRepository,
    required this.exerciseLibraryRepository,
    required this.bodyWeightRepository,
    required this.nutritionRepository,
    super.key,
  });

  /// Provides saved workout data to the workout tab.
  final WorkoutRepository workoutRepository;

  /// Provides local exercise library data.
  final ExerciseLibraryRepository exerciseLibraryRepository;
  final BodyWeightRepository bodyWeightRepository;
  final NutritionRepository nutritionRepository;

  @override
  State<JournalHome> createState() => _JournalHomeState();
}

class _JournalHomeState extends State<JournalHome> {
  int selectedTab = 0;
  DateTime selectedDate = DateTime.now();
  List<Workout> savedWorkouts = [];
  WorkoutLoadStatus? workoutLoadStatus;
  List<BodyWeightEntry> bodyWeightEntries = [];
  bool bodyWeightIsLoading = true;
  bool bodyWeightLoadError = false;
  List<NutritionEntry> nutritionEntries = [];
  bool nutritionIsLoading = true;
  bool nutritionLoadError = false;

  void _workoutsChanged(List<Workout> workouts) {
    setState(() => savedWorkouts = workouts);
  }

  void _workoutLoadStatusChanged(WorkoutLoadStatus status) {
    setState(() => workoutLoadStatus = status);
  }

  void _bodyWeightEntriesChanged(List<BodyWeightEntry> entries) {
    setState(() {
      bodyWeightEntries = entries;
      bodyWeightIsLoading = false;
      bodyWeightLoadError = false;
    });
  }

  void _bodyWeightLoadFinished(bool succeeded) {
    setState(() {
      bodyWeightIsLoading = false;
      bodyWeightLoadError = !succeeded;
    });
  }

  void _nutritionEntriesChanged(List<NutritionEntry> entries) {
    setState(() {
      nutritionEntries = entries;
      nutritionIsLoading = false;
      nutritionLoadError = false;
    });
  }

  void _nutritionLoadFinished(bool succeeded) {
    setState(() {
      nutritionIsLoading = false;
      nutritionLoadError = !succeeded;
    });
  }

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

  Widget homePage() => DashboardPage(
    workouts: savedWorkouts,
    selectedDate: selectedDate,
    isLoading: workoutLoadStatus == null,
    hasLoadError: workoutLoadStatus == WorkoutLoadStatus.failed,
    bodyWeightEntries: bodyWeightEntries,
    isBodyWeightLoading: bodyWeightIsLoading,
    bodyWeightLoadError: bodyWeightLoadError,
    nutritionEntries: nutritionEntries,
    isNutritionLoading: nutritionIsLoading,
    nutritionLoadError: nutritionLoadError,
    onOpenWorkout: () => setState(() => selectedTab = 1),
    onOpenStatistics: _openWorkoutStatistics,
    onOpenMeals: () => setState(() => selectedTab = 2),
    onOpenWeight: () => setState(() => selectedTab = 3),
  );

  void _openWorkoutStatistics() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            WorkoutStatisticsPage(repository: widget.workoutRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homePage(),
      WorkoutPage(
        repository: widget.workoutRepository,
        exerciseLibraryRepository: widget.exerciseLibraryRepository,
        selectedDate: selectedDate,
        onWorkoutsChanged: _workoutsChanged,
        onLoadStatusChanged: _workoutLoadStatusChanged,
      ),
      NutritionPage(
        repository: widget.nutritionRepository,
        selectedDate: selectedDate,
        onEntriesChanged: _nutritionEntriesChanged,
        onLoadFinished: _nutritionLoadFinished,
      ),
      WeightPage(
        repository: widget.bodyWeightRepository,
        selectedDate: selectedDate,
        onEntriesChanged: _bodyWeightEntriesChanged,
        onLoadFinished: _bodyWeightLoadFinished,
      ),
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
