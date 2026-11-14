import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/features/progress/weight_page.dart';
import '../../support/fake_body_weight_repository.dart';

void main() {
  testWidgets('shows an empty state and saves a daily weight', (tester) async {
    final repository = FakeBodyWeightRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightPage(
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
      find.text('No weight entries yet. Record your first measurement above.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('weight-value-field')),
      '73.2',
    );
    await tester.tap(find.byKey(const ValueKey('save-weight-entry')));
    await tester.pumpAndSettle();

    expect((await repository.getAll()).single.weightKg, 73.2);
    expect(find.text('73.2 kg'), findsOneWidget);
  });

  testWidgets('allows editing and deleting a saved weight', (tester) async {
    final repository = FakeBodyWeightRepository();
    await repository.save(
      BodyWeightEntry(date: DateTime(2026, 11, 14), weightKg: 70),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightPage(
            repository: repository,
            selectedDate: DateTime(2026, 11, 14),
            onEntriesChanged: (_) {},
            onLoadFinished: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit weight'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('weight-edit-field')),
      '71.5',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await repository.getAll()).single.weightKg, 71.5);

    await tester.tap(find.byTooltip('Delete weight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await repository.getAll(), isEmpty);
    expect(
      find.text('No weight entries yet. Record your first measurement above.'),
      findsOneWidget,
    );
  });
}
