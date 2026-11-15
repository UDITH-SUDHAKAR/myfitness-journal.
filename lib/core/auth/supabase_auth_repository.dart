import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'auth_repository.dart';
import 'auth_user.dart';
import 'google_sign_in_gateway.dart';

/// Supabase Auth implementation using native Google Sign-In credentials.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required SupabaseClient client,
    required GoogleSignInGateway googleSignIn,
  }) : _client = client,
       _googleSignIn = googleSignIn;

  final SupabaseClient _client;
  final GoogleSignInGateway _googleSignIn;

  @override
  AuthUser? get currentUser => _client.auth.currentUser == null
      ? null
      : _mapUser(_client.auth.currentUser!);

  @override
  Stream<AuthRepositoryEvent> get authEvents =>
      _client.auth.onAuthStateChange.map(
        (state) => AuthRepositoryEvent(
          user: state.session?.user == null
              ? null
              : _mapUser(state.session!.user),
          isInitialSession: state.event == AuthChangeEvent.initialSession,
          isSignedOut: state.event == AuthChangeEvent.signedOut,
        ),
      );

  @override
  Future<AuthUser?> signInWithGoogle() async {
    final tokens = await _googleSignIn.signIn();
    if (tokens == null) return null;

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: tokens.idToken,
      accessToken: tokens.accessToken,
    );
    final user = response.user;
    if (user == null) {
      throw StateError('Supabase did not return a signed-in user.');
    }
    return _mapUser(user);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut(scope: SignOutScope.local);
    // Supabase has already cleared its local session. Google sign-out only
    // clears the account selected by the native Google picker.
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Do not prevent the user from leaving the journal if Google cleanup
      // cannot reach its platform service.
    }
  }

  static AuthUser _mapUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    return AuthUser(
      id: user.id,
      name: _firstString(metadata, const ['full_name', 'name']),
      email: user.email,
      avatarUrl: _firstString(metadata, const ['avatar_url', 'picture']),
    );
  }

  static String? _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
