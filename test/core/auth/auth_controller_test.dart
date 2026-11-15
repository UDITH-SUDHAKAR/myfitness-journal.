import 'package:flutter_test/flutter_test.dart';
import 'package:myfitness_journal/core/auth/auth_controller.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  test('restores a locally persisted Supabase user', () async {
    final repository = FakeAuthRepository(user: testAuthUser);
    final controller = AuthController(repository: repository);

    expect(controller.state.status, AuthStatus.signedIn);
    expect(controller.state.user?.id, testAuthUser.id);

    controller.dispose();
    await repository.dispose();
  });

  test('waits for the initial empty session before showing login', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository: repository);
    expect(controller.state.status, AuthStatus.initializing);

    repository.emitInitialSession();
    expect(controller.state.status, AuthStatus.signedOut);

    controller.dispose();
    await repository.dispose();
  });

  test(
    'Google sign-in updates state and cancellation is not an error',
    () async {
      final repository = FakeAuthRepository(nextSignInUser: testAuthUser);
      final controller = AuthController(repository: repository);
      repository.emitInitialSession();

      await controller.signInWithGoogle();
      expect(controller.state.status, AuthStatus.signedIn);
      expect(controller.state.user?.email, 'journal@example.com');

      await controller.signOut();
      repository.nextSignInUser = null;
      await controller.signInWithGoogle();
      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.error, isNull);

      controller.dispose();
      await repository.dispose();
    },
  );

  test(
    'reports Google sign-in failures and keeps offline access available',
    () async {
      final repository = FakeAuthRepository()
        ..signInError = Exception('No network');
      final controller = AuthController(repository: repository);
      repository.emitInitialSession();

      await controller.signInWithGoogle();
      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.error, contains('No network'));

      controller.continueOffline();
      expect(controller.state.status, AuthStatus.offline);

      controller.dispose();
      await repository.dispose();
    },
  );

  test(
    'logout clears auth state without deleting local journal data',
    () async {
      final repository = FakeAuthRepository(user: testAuthUser);
      final controller = AuthController(repository: repository);

      await controller.signOut();
      expect(repository.signOutCalls, 1);
      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.user, isNull);

      controller.dispose();
      await repository.dispose();
    },
  );

  test('initial session events do not undo Continue Offline', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository: repository);
    repository.emitInitialSession();
    controller.continueOffline();
    repository.emitInitialSession();

    expect(controller.state.status, AuthStatus.offline);

    controller.dispose();
    await repository.dispose();
  });

  test(
    'stream errors preserve an authenticated user for offline access',
    () async {
      final repository = FakeAuthRepository(user: testAuthUser);
      final controller = AuthController(repository: repository);

      // A stream error is emitted by Supabase for conditions such as an offline
      // refresh. The controller keeps the last known local account scope.
      repository.emitInitialSession();
      repository.emitError(Exception('Offline refresh failed'));
      expect(controller.state.status, AuthStatus.signedIn);
      expect(controller.state.user?.id, testAuthUser.id);
      expect(controller.state.error, contains('Offline refresh failed'));

      controller.dispose();
      await repository.dispose();
    },
  );
}
