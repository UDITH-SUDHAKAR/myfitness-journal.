import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/models/body_weight_entry.dart';
import 'package:myfitness_journal/core/storage/body_weight_repository.dart';
import 'package:myfitness_journal/features/progress/weight_page.dart';
import '../../support/fake_body_weight_repository.dart';

void main() {
  testWidgets('shows an empty state and saves a daily weight', (tester) async {
    final repository = FakeBodyWeightRepository();
    final today = DateUtils.dateOnly(DateTime.now());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightPage(
            repository: repository,
            selectedDate: today,
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
    expect(
      find.text('Record weight to start building your progress chart.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('weight-value-field')),
      '73.2',
    );
    await tester.tap(find.byKey(const ValueKey('save-weight-entry')));
    await tester.pumpAndSettle();

    expect((await repository.getAll()).single.weightKg, 73.2);
    await _scrollToWeightHistory(tester);
    expect(find.text('73.2 kg'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('body-weight-progress-chart')),
      findsOneWidget,
    );
    expect(find.textContaining('Latest: 73.2 kg'), findsOneWidget);
    expect(find.text('Not enough entries to show a change'), findsOneWidget);
  });

  testWidgets('allows editing and deleting a saved weight', (tester) async {
    final repository = FakeBodyWeightRepository();
    final today = DateUtils.dateOnly(DateTime.now());
    await repository.save(BodyWeightEntry(date: today, weightKg: 70));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightPage(
            repository: repository,
            selectedDate: today,
            onEntriesChanged: (_) {},
            onLoadFinished: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToWeightHistory(tester);
    await tester.tap(find.byTooltip('Edit weight'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('weight-edit-field')),
      '71.5',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await repository.getAll()).single.weightKg, 71.5);
    expect(find.textContaining('Latest: 71.5 kg'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Delete weight'));
    await tester.tap(find.byTooltip('Delete weight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await repository.getAll(), isEmpty);
    expect(
      find.text('No weight entries yet. Record your first measurement above.'),
      findsOneWidget,
    );
    expect(
      find.text('Record weight to start building your progress chart.'),
      findsOneWidget,
    );
  });

  testWidgets('switches between 12-week and 12-month chart windows', (
    tester,
  ) async {
    final repository = FakeBodyWeightRepository();
    final today = DateUtils.dateOnly(DateTime.now());
    await repository.save(
      BodyWeightEntry(
        date: today.subtract(const Duration(days: 100)),
        weightKg: 75,
      ),
    );
    await repository.save(
      BodyWeightEntry(
        date: today.subtract(const Duration(days: 5)),
        weightKg: 73,
      ),
    );

    await _pumpWeightPage(tester, repository, selectedDate: today);

    expect(
      find.byKey(const ValueKey('body-weight-progress-chart')),
      findsOneWidget,
    );
    expect(find.text('Not enough entries to show a change'), findsOneWidget);

    await tester.tap(find.text('12 months'));
    await tester.pumpAndSettle();

    expect(find.text('Absolute change: 2.0 kg (decrease)'), findsOneWidget);
    expect(
      find.textContaining('Only recorded measurements are plotted.'),
      findsOneWidget,
    );
    final chart = tester.widget<LineChart>(
      find.descendant(
        of: find.byKey(const ValueKey('body-weight-progress-chart')),
        matching: find.byType(LineChart),
      ),
    );
    expect(chart.data.lineBarsData, hasLength(2));
    expect(
      chart.data.lineBarsData.every((line) => line.spots.length == 1),
      isTrue,
    );
  });

  testWidgets(
    'shows an empty-period state when older history is outside range',
    (tester) async {
      final repository = FakeBodyWeightRepository();
      final today = DateUtils.dateOnly(DateTime.now());
      await repository.save(
        BodyWeightEntry(
          date: DateTime(today.year - 2, today.month, today.day),
          weightKg: 70,
        ),
      );

      await _pumpWeightPage(tester, repository, selectedDate: today);

      expect(
        find.text('No weight entries in the last 12 weeks.'),
        findsOneWidget,
      );
      expect(find.text('Weight history'), findsOneWidget);
      expect(find.byKey(const ValueKey('weight-entry-1')), findsOneWidget);
    },
  );

  testWidgets('shows chart loading and repository error states', (
    tester,
  ) async {
    final deferred = _DeferredBodyWeightRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightPage(
            repository: deferred,
            selectedDate: DateTime.now(),
            onEntriesChanged: (_) {},
            onLoadFinished: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Loading weight progress...'), findsOneWidget);
    deferred.completer.completeError(StateError('Temporary read failure.'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load weight progress.'), findsOneWidget);

    deferred.shouldFail = false;
    await tester.tap(find.text('Try again').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Record weight to start building your progress chart.'),
      findsOneWidget,
    );
  });

  testWidgets('refreshes the weight summary after edit and delete', (
    tester,
  ) async {
    final repository = FakeBodyWeightRepository();
    final today = DateUtils.dateOnly(DateTime.now());
    await repository.save(
      BodyWeightEntry(
        date: today.subtract(const Duration(days: 5)),
        weightKg: 72,
      ),
    );
    await repository.save(BodyWeightEntry(date: today, weightKg: 70));

    await _pumpWeightPage(tester, repository, selectedDate: today);
    expect(find.text('Absolute change: 2.0 kg (decrease)'), findsOneWidget);

    await _scrollToWeightHistory(tester);
    await tester.tap(find.byTooltip('Edit weight').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('weight-edit-field')),
      '74',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Absolute change: 2.0 kg (increase)'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Delete weight').first);
    await tester.tap(find.byTooltip('Delete weight').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Not enough entries to show a change'), findsOneWidget);
  });
}

Future<void> _scrollToWeightHistory(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Weight history'),
    250,
    scrollable: find.byType(Scrollable).first,
  );
}

Future<void> _pumpWeightPage(
  WidgetTester tester,
  BodyWeightRepository repository, {
  required DateTime selectedDate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WeightPage(
          repository: repository,
          selectedDate: selectedDate,
          onEntriesChanged: (_) {},
          onLoadFinished: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _DeferredBodyWeightRepository extends FakeBodyWeightRepository {
  final Completer<List<BodyWeightEntry>> completer =
      Completer<List<BodyWeightEntry>>();
  bool shouldFail = true;

  @override
  Future<List<BodyWeightEntry>> getAll() {
    if (completer.isCompleted && shouldFail) return Future.error('failed');
    if (!completer.isCompleted) return completer.future;
    return super.getAll();
  }
}
