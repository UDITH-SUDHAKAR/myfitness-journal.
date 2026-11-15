import 'dart:async';

import 'package:myfitness_journal/core/auth/auth_repository.dart';
import 'package:myfitness_journal/core/auth/auth_user.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user, this.nextSignInUser});

  final StreamController<AuthRepositoryEvent> _events =
      StreamController<AuthRepositoryEvent>.broadcast(sync: true);

  AuthUser? user;

  AuthUser? nextSignInUser;
  Object? signInError;
  Object? signOutError;
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthRepositoryEvent> get authEvents => _events.stream;

  void emitInitialSession() {
    _events.add(
      AuthRepositoryEvent(
        user: user,
        isInitialSession: true,
        isSignedOut: false,
      ),
    );
  }

  void emitError(Object error) => _events.addError(error, StackTrace.current);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    signInCalls++;
    final error = signInError;
    if (error != null) throw error;
    user = nextSignInUser;
    final signedInUser = user;
    if (signedInUser != null) {
      _events.add(
        AuthRepositoryEvent(
          user: signedInUser,
          isInitialSession: false,
          isSignedOut: false,
        ),
      );
    }
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    final error = signOutError;
    if (error != null) throw error;
    user = null;
    _events.add(
      const AuthRepositoryEvent(
        user: null,
        isInitialSession: false,
        isSignedOut: true,
      ),
    );
  }

  Future<void> dispose() => _events.close();
}

const testAuthUser = AuthUser(
  id: '12345678-1234-1234-1234-123456789abc',
  name: 'Journal User',
  email: 'journal@example.com',
  avatarUrl: 'https://example.com/avatar.png',
);
