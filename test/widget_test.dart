// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:myfitness_journal/main.dart';
import 'support/fake_workout_repository.dart';

void main() {
  testWidgets('home and existing tabs remain available', (tester) async {
    await tester.pumpWidget(
      MyFitnessApp(workoutRepository: FakeWorkoutRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Myfitness Journal'), findsOneWidget);
    expect(find.text('Your fitness journey starts here.'), findsOneWidget);

    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();
    expect(find.text('Workout history'), findsOneWidget);
    expect(find.text('Start workout'), findsOneWidget);

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    expect(find.text('Nutrition tracking is coming next.'), findsOneWidget);

    await tester.tap(find.text('Weight'));
    await tester.pumpAndSettle();
    expect(find.text('Daily weight (kg)'), findsOneWidget);
  });
}
