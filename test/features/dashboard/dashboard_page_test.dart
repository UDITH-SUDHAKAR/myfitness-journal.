import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/features/dashboard/dashboard_page.dart';

Widget buildDashboard({
  List<Workout> workouts = const [],
  DateTime? selectedDate,
  bool isLoading = false,
  bool hasLoadError = false,
  double? weight,
  VoidCallback? onWorkout,
  VoidCallback? onWeight,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DashboardPage(
        workouts: workouts,
        selectedDate: selectedDate ?? DateTime.now(),
        isLoading: isLoading,
        hasLoadError: hasLoadError,
        selectedDateWeight: weight,
        onOpenWorkout: onWorkout ?? () {},
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
    expect(find.text('Your saved workouts will appear here.'), findsOneWidget);
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
        weight: 72.5,
      ),
    );

    expect(find.text('2 exercises logged'), findsOneWidget);
    expect(find.text('1 workout session'), findsOneWidget);
    expect(find.text('Weight: 72.5 kg'), findsOneWidget);
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

    expect(find.text('4'), findsOneWidget);
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
    var weightOpened = false;
    await tester.pumpWidget(
      buildDashboard(
        onWorkout: () => workoutOpened = true,
        onWeight: () => weightOpened = true,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('dashboard-open-workout')));
    expect(workoutOpened, isTrue);
    await tester.tap(find.byKey(const ValueKey('dashboard-open-weight')));
    expect(weightOpened, isTrue);
  });
}
