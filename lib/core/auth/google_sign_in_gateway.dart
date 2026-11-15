import 'package:google_sign_in/google_sign_in.dart';

/// Google tokens required by Supabase's native ID-token sign-in flow.
class GoogleSignInTokens {
  const GoogleSignInTokens({required this.idToken, required this.accessToken});

  final String idToken;
  final String accessToken;
}

/// Small wrapper that makes native Google sign-in replaceable in tests.
abstract interface class GoogleSignInGateway {
  Future<GoogleSignInTokens?> signIn();

  Future<void> signOut();
}

/// Gets native Google credentials from the platform's Google Sign-In plugin.
class NativeGoogleSignInGateway implements GoogleSignInGateway {
  NativeGoogleSignInGateway({required String serverClientId})
    : _googleSignIn = GoogleSignIn(
        serverClientId: serverClientId.isEmpty ? null : serverClientId,
      );

  final GoogleSignIn _googleSignIn;

  @override
  Future<GoogleSignInTokens?> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    final accessToken = authentication.accessToken;
    if (idToken == null || accessToken == null) {
      throw StateError('Google did not return the required sign-in tokens.');
    }

    return GoogleSignInTokens(idToken: idToken, accessToken: accessToken);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
