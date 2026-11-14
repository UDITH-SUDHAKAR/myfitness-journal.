import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/exercise_library_item.dart';
import 'package:myfitness_journal/features/workouts/exercise_library_page.dart';

import '../../support/fake_exercise_library_repository.dart';

void main() {
  testWidgets('library entries can be edited, searched, and deleted', (
    tester,
  ) async {
    final repository = FakeExerciseLibraryRepository();
    await repository.save(
      ExerciseLibraryItem(
        name: 'Cable Row',
        muscleGroup: 'Back',
        equipment: 'Cable',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: ExerciseLibraryPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cable Row'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('library-exercise-name')),
      'Seated Cable Row',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('library-search')),
      'seated',
    );
    await tester.pumpAndSettle();
    expect(find.text('Seated Cable Row'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete Seated Cable Row'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(repository.items, isEmpty);
  });
}
