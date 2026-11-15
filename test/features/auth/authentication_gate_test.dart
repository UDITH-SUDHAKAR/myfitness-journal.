import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/auth/auth_controller.dart';
import 'package:myfitness_journal/features/auth/account_dialog.dart';
import 'package:myfitness_journal/features/auth/authentication_gate.dart';
import 'package:myfitness_journal/features/auth/login_page.dart';
import 'package:myfitness_journal/main.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_body_weight_repository.dart';
import '../../support/fake_exercise_library_repository.dart';
import '../../support/fake_food_repository.dart';
import '../../support/fake_meal_repository.dart';
import '../../support/fake_nutrition_repository.dart';
import '../../support/fake_workout_repository.dart';

void main() {
  testWidgets('restores auth state and offers Continue Offline', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository: repository);
    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticationGate(
          controller: controller,
          journalBuilder: (userId) async => Scaffold(
            body: Text(userId == null ? 'Offline journal' : 'Account journal'),
          ),
        ),
      ),
    );
    expect(find.text('Restoring your session...'), findsOneWidget);

    repository.emitInitialSession();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('continue-offline')));
    await tester.pumpAndSettle();
    expect(find.text('Offline journal'), findsOneWidget);

    controller.dispose();
    await repository.dispose();
  });

  testWidgets('Google sign-in opens the journal for that user ID', (
    tester,
  ) async {
    final repository = FakeAuthRepository(nextSignInUser: testAuthUser);
    final controller = AuthController(repository: repository);
    repository.emitInitialSession();
    String? openedUserId;

    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticationGate(
          controller: controller,
          journalBuilder: (userId) async {
            openedUserId = userId;
            return const Scaffold(body: Text('Account journal'));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('google-sign-in')));
    await tester.pumpAndSettle();

    expect(openedUserId, testAuthUser.id);
    expect(find.text('Account journal'), findsOneWidget);

    controller.dispose();
    await repository.dispose();
  });

  testWidgets('sign-in errors are visible and offline remains available', (
    tester,
  ) async {
    final repository = FakeAuthRepository()
      ..signInError = Exception('Network unavailable');
    final controller = AuthController(repository: repository);
    repository.emitInitialSession();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticationGate(
          controller: controller,
          journalBuilder: (userId) async =>
              const Scaffold(body: Text('Offline journal')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('google-sign-in')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('authentication-error')), findsOneWidget);
    expect(find.byKey(const ValueKey('continue-offline')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('continue-offline')));
    await tester.pumpAndSettle();
    expect(find.text('Offline journal'), findsOneWidget);

    controller.dispose();
    await repository.dispose();
  });

  testWidgets('unconfigured Supabase still allows offline access', (
    tester,
  ) async {
    final controller = AuthController(
      repository: null,
      unavailableMessage: 'Configure Supabase to enable sign-in.',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticationGate(
          controller: controller,
          journalBuilder: (userId) async =>
              const Scaffold(body: Text('Offline journal')),
        ),
      ),
    );

    expect(find.text('Configure Supabase to enable sign-in.'), findsOneWidget);
    expect(find.byKey(const ValueKey('google-sign-in')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('google-sign-in')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('continue-offline')));
    await tester.pumpAndSettle();
    expect(find.text('Offline journal'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('account UI displays Google profile and signs out locally', (
    tester,
  ) async {
    final repository = FakeAuthRepository(user: testAuthUser);
    final controller = AuthController(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => AccountDialog(controller: controller),
              ),
              child: const Text('Open account'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open account'));
    await tester.pumpAndSettle();

    expect(find.text('Journal User'), findsOneWidget);
    expect(find.text('journal@example.com'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('account-sign-out')));
    await tester.pumpAndSettle();
    expect(repository.signOutCalls, 1);
    expect(controller.state.status, AuthStatus.signedOut);

    controller.dispose();
    await repository.dispose();
  });

  testWidgets('authenticated journal preserves the four existing tabs', (
    tester,
  ) async {
    final repository = FakeAuthRepository(user: testAuthUser);
    final controller = AuthController(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticationGate(
          controller: controller,
          journalBuilder: (_) async => JournalHome(
            workoutRepository: FakeWorkoutRepository(),
            exerciseLibraryRepository: FakeExerciseLibraryRepository(),
            bodyWeightRepository: FakeBodyWeightRepository(),
            nutritionRepository: FakeNutritionRepository(),
            foodRepository: FakeFoodRepository(),
            mealRepository: FakeMealRepository(),
            authController: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your fitness journey starts here.'), findsOneWidget);
    await tester.tap(find.text('Workout').last);
    await tester.pumpAndSettle();
    expect(find.text('Workout history'), findsOneWidget);
    await tester.tap(find.text('Meals').last);
    await tester.pumpAndSettle();
    expect(find.text('Add food or meal'), findsOneWidget);
    await tester.tap(find.text('Weight').last);
    await tester.pumpAndSettle();
    expect(find.text('Daily weight (kg)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('journal-account-button')),
      findsOneWidget,
    );

    controller.dispose();
    await repository.dispose();
  });
}
