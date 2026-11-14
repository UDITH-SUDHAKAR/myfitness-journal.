import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/core/models/nutrition_entry.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/features/dashboard/dashboard_page.dart';

Widget buildDashboard({
  List<Workout> workouts = const [],
  DateTime? selectedDate,
  bool isLoading = false,
  bool hasLoadError = false,
  List<BodyWeightEntry> bodyWeightEntries = const [],
  bool isBodyWeightLoading = false,
  bool bodyWeightLoadError = false,
  List<NutritionEntry> nutritionEntries = const [],
  bool isNutritionLoading = false,
  bool nutritionLoadError = false,
  VoidCallback? onWorkout,
  VoidCallback? onStatistics,
  VoidCallback? onMeals,
  VoidCallback? onWeight,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DashboardPage(
        workouts: workouts,
        selectedDate: selectedDate ?? DateTime.now(),
        isLoading: isLoading,
        hasLoadError: hasLoadError,
        bodyWeightEntries: bodyWeightEntries,
        isBodyWeightLoading: isBodyWeightLoading,
        bodyWeightLoadError: bodyWeightLoadError,
        nutritionEntries: nutritionEntries,
        isNutritionLoading: isNutritionLoading,
        nutritionLoadError: nutritionLoadError,
        onOpenWorkout: onWorkout ?? () {},
        onOpenStatistics: onStatistics ?? () {},
        onOpenMeals: onMeals ?? () {},
        onOpenWeight: onWeight ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('distinguishes loading from empty workout history', (
    tester,
  ) async {
    await tester.pumpWidget(buildDashboard(isLoading: true));
    expect(find.text('Loading workout activity…'), findsOneWidget);
    expect(find.text('No workouts logged for this day.'), findsNothing);

    await tester.pumpWidget(buildDashboard());
    expect(find.text('No workouts logged for this day.'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('dashboard-list')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('dashboard-empty-recent')),
    );
    expect(find.text('Your saved workouts will appear here.'), findsOneWidget);
  });

  testWidgets('shows load errors separately from empty data', (tester) async {
    await tester.pumpWidget(
      buildDashboard(
        hasLoadError: true,
        bodyWeightLoadError: true,
        nutritionLoadError: true,
      ),
    );

    expect(find.text('Workout activity could not be loaded.'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('dashboard-list')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(find.text('Weight history could not be loaded.'), findsOneWidget);
    expect(find.text('Nutrition entries could not be loaded.'), findsOneWidget);
    expect(find.text('No weight entries yet.'), findsNothing);
    expect(find.text('No nutrition entries for this day.'), findsNothing);
  });

  testWidgets('shows selected-day totals and weight using calendar dates', (
    tester,
  ) async {
    final selectedDay = DateTime(2026, 11, 12);
    final workouts = [
      Workout(
        date: DateTime(2026, 11, 12, 22),
        exercises: [
          Exercise(name: 'Squat'),
          Exercise(name: 'Press'),
        ],
      ),
      Workout(
        date: DateTime(2026, 11, 13),
        exercises: [Exercise(name: 'Row')],
      ),
    ];

    await tester.pumpWidget(
      buildDashboard(
        workouts: workouts,
        selectedDate: selectedDay,
        bodyWeightEntries: [
          BodyWeightEntry(date: DateTime(2026, 11, 12), weightKg: 72.5),
        ],
        nutritionEntries: [
          NutritionEntry(
            date: DateTime(2026, 11, 12, 12),
            name: 'Lunch',
            calories: 650,
            proteinGrams: 35,
          ),
        ],
      ),
    );

    expect(find.text('2 exercises logged'), findsOneWidget);
    expect(find.text('1 workout session'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('dashboard-list')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('dashboard-latest-weight')),
    );
    expect(find.text('72.5 kg · 12 Nov 2026'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('dashboard-daily-nutrition')),
    );
    expect(find.text('650 kcal · 35.0 g protein'), findsOneWidget);
  });

  testWidgets('counts sessions Monday through Sunday and shows three newest', (
    tester,
  ) async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final monday = todayOnly.subtract(Duration(days: todayOnly.weekday - 1));
    final workouts = [
      for (var offset = 0; offset < 4; offset++)
        Workout(
          date: monday.add(Duration(days: offset)),
          exercises: [Exercise(name: 'Lift $offset')],
        ),
      Workout(
        date: monday.subtract(const Duration(days: 1)),
        exercises: [Exercise(name: 'Outside week')],
      ),
    ];

    await tester.pumpWidget(
      buildDashboard(workouts: workouts, selectedDate: monday),
    );

    expect(
      (tester.widget(find.byKey(const ValueKey('dashboard-weekly-count')))
              as Text)
          .data,
      '4',
    );
    expect(find.text('1 exercise logged'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('dashboard-list')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    final recentTiles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .toList();
    expect(recentTiles, hasLength(3));
    final recentDates = recentTiles
        .map((tile) => (tile.title! as Text).data)
        .toList();
    expect(recentDates, [
      DateFormat('EEE, d MMM yyyy').format(monday.add(const Duration(days: 3))),
      DateFormat('EEE, d MMM yyyy').format(monday.add(const Duration(days: 2))),
      DateFormat('EEE, d MMM yyyy').format(monday.add(const Duration(days: 1))),
    ]);
  });

  testWidgets('quick actions call existing navigation callbacks', (
    tester,
  ) async {
    var workoutOpened = false;
    var statisticsOpened = false;
    var mealsOpened = false;
    var weightOpened = false;
    await tester.pumpWidget(
      buildDashboard(
        onWorkout: () => workoutOpened = true,
        onStatistics: () => statisticsOpened = true,
        onMeals: () => mealsOpened = true,
        onWeight: () => weightOpened = true,
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('dashboard-list')),
      const Offset(0, -1400),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('dashboard-open-workout')),
    );
    await tester.tap(find.byKey(const ValueKey('dashboard-open-workout')));
    expect(workoutOpened, isTrue);
    await tester.tap(find.byKey(const ValueKey('dashboard-open-statistics')));
    expect(statisticsOpened, isTrue);
    await tester.tap(find.byKey(const ValueKey('dashboard-open-meals')));
    expect(mealsOpened, isTrue);
    await tester.tap(find.byKey(const ValueKey('dashboard-open-weight')));
    expect(weightOpened, isTrue);
  });
}
