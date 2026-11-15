import 'auth_user.dart';

/// Auth event delivered when Supabase restores or changes a session.
class AuthRepositoryEvent {
  const AuthRepositoryEvent({
    required this.user,
    required this.isInitialSession,
    required this.isSignedOut,
  });

  final AuthUser? user;
  final bool isInitialSession;
  final bool isSignedOut;
}

/// Authentication operations needed by the app.
abstract interface class AuthRepository {
  /// User from the session currently available in local auth storage.
  AuthUser? get currentUser;

  /// Emits the restored session and subsequent sign-in/sign-out events.
  Stream<AuthRepositoryEvent> get authEvents;

  /// Signs in with Google, or returns null if the user cancels.
  Future<AuthUser?> signInWithGoogle();

  /// Signs out this device's session only.
  Future<void> signOut();
}
