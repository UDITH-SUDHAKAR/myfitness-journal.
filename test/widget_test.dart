// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/core/models/exercise.dart';
import 'package:myfitness_journal/core/models/nutrition_entry.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/models/workout_set.dart';

import 'package:myfitness_journal/main.dart';
import 'support/fake_workout_repository.dart';
import 'support/fake_exercise_library_repository.dart';
import 'support/fake_body_weight_repository.dart';
import 'support/fake_nutrition_repository.dart';

void main() {
  testWidgets('home and existing tabs remain available', (tester) async {
    await tester.pumpWidget(
      MyFitnessApp(
        workoutRepository: FakeWorkoutRepository(),
        exerciseLibraryRepository: FakeExerciseLibraryRepository(),
        bodyWeightRepository: FakeBodyWeightRepository(),
        nutritionRepository: FakeNutritionRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Myfitness Journal'), findsOneWidget);
    expect(find.text('Your fitness journey starts here.'), findsOneWidget);

    await tester.tap(find.text('Workout').last);
    await tester.pumpAndSettle();
    expect(find.text('Workout history'), findsOneWidget);
    expect(find.text('Start workout'), findsOneWidget);

    await tester.tap(find.text('Meals').last);
    await tester.pumpAndSettle();
    expect(find.text('Add food or meal'), findsOneWidget);

    await tester.tap(find.text('Weight').last);
    await tester.pumpAndSettle();
    expect(find.text('Daily weight (kg)'), findsOneWidget);
  });

  testWidgets(
    'dashboard summaries come from repositories and quick actions navigate',
    (tester) async {
      final workoutRepository = FakeWorkoutRepository();
      final weightRepository = FakeBodyWeightRepository();
      final nutritionRepository = FakeNutritionRepository();
      final today = DateUtils.dateOnly(DateTime.now());
      await workoutRepository.save(
        Workout(
          date: today,
          exercises: [
            Exercise(name: 'Squat', sets: [WorkoutSet(weight: 50, reps: 8)]),
          ],
        ),
      );
      await weightRepository.save(BodyWeightEntry(date: today, weightKg: 70.5));
      await nutritionRepository.save(
        NutritionEntry(
          date: today,
          name: 'Breakfast',
          calories: 350,
          proteinGrams: 20,
        ),
      );

      await tester.pumpWidget(
        MyFitnessApp(
          workoutRepository: workoutRepository,
          exerciseLibraryRepository: FakeExerciseLibraryRepository(),
          bodyWeightRepository: weightRepository,
          nutritionRepository: nutritionRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All time: 1 workout'), findsOneWidget);
      await tester.drag(
        find.byKey(const ValueKey('dashboard-list')),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('dashboard-training-summary')),
      );
      expect(find.text('1 exercise · 1 sets · 8 reps'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('dashboard-latest-weight')),
      );
      expect(
        find.text('70.5 kg · ${DateFormat('d MMM yyyy').format(today)}'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('dashboard-daily-nutrition')),
      );
      expect(find.text('350 kcal · 20.0 g protein'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const ValueKey('dashboard-open-meals')),
      );
      await tester.tap(find.byKey(const ValueKey('dashboard-open-meals')));
      await tester.pumpAndSettle();
      expect(find.text('Add food or meal'), findsOneWidget);
    },
  );
}
