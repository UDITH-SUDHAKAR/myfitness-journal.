import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/features/nutrition/nutrition_page.dart';
import '../../support/fake_nutrition_repository.dart';

void main() {
  testWidgets('shows an empty state and sums multiple selected-day entries', (
    tester,
  ) async {
    final repository = FakeNutritionRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NutritionPage(
            repository: repository,
            selectedDate: DateTime(2026, 11, 14),
            onEntriesChanged: (_) {},
            onLoadFinished: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No nutrition entries logged for this day.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('nutrition-name-field')),
      'Breakfast',
    );
    await tester.enterText(
      find.byKey(const ValueKey('nutrition-calories-field')),
      '400',
    );
    await tester.enterText(
      find.byKey(const ValueKey('nutrition-protein-field')),
      '22.5',
    );
    await tester.tap(find.byKey(const ValueKey('save-nutrition-entry')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('nutrition-name-field')),
      'Dinner',
    );
    await tester.enterText(
      find.byKey(const ValueKey('nutrition-calories-field')),
      '700',
    );
    await tester.enterText(
      find.byKey(const ValueKey('nutrition-protein-field')),
      '31',
    );
    await tester.tap(find.byKey(const ValueKey('save-nutrition-entry')));
    await tester.pumpAndSettle();

    expect(find.text('1100 kcal · 53.5 g protein'), findsOneWidget);
    expect(await repository.getAll(), hasLength(2));
  });
}
