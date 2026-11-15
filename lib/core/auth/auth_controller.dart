import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_repository.dart';
import 'auth_user.dart';

/// Top-level authentication and local-access modes shown by the app.
enum AuthStatus { initializing, signedOut, offline, signedIn, unavailable }

/// Immutable state consumed by the authentication gate and account UI.
@immutable
class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.isBusy = false,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? error;
  final bool isBusy;
}

/// Coordinates authentication events and user choices in the interface.
class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository? repository,
    String? unavailableMessage,
  }) : _repository = repository,
       _state = AuthState(
         status: repository == null
             ? AuthStatus.unavailable
             : repository.currentUser == null
             ? AuthStatus.initializing
             : AuthStatus.signedIn,
         user: repository?.currentUser,
         error: repository == null ? unavailableMessage : null,
       ) {
    if (_repository != null) {
      _subscription = _repository.authEvents.listen(
        _handleAuthEvent,
        onError: _handleStreamError,
      );
    }
  }

  final AuthRepository? _repository;
  StreamSubscription<AuthRepositoryEvent>? _subscription;
  AuthState _state;

  /// Current authentication and offline mode.
  AuthState get state => _state;

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _handleAuthEvent(AuthRepositoryEvent event) {
    if (event.user != null) {
      _setState(AuthState(status: AuthStatus.signedIn, user: event.user));
    } else if (event.isSignedOut || event.isInitialSession) {
      // An initial empty session should not undo a Continue Offline choice.
      if (_state.status != AuthStatus.offline) {
        _setState(const AuthState(status: AuthStatus.signedOut));
      }
    }
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    final message = _friendlyError(error);
    if (_state.status == AuthStatus.initializing) {
      _setState(AuthState(status: AuthStatus.signedOut, error: message));
    } else {
      _setState(
        AuthState(
          status: _state.status,
          user: _state.user,
          error: message,
          isBusy: _state.isBusy,
        ),
      );
    }
  }

  /// Chooses the existing device-only journal without signing in.
  void continueOffline() {
    if (_state.status == AuthStatus.signedIn) return;
    _setState(const AuthState(status: AuthStatus.offline));
  }

  /// Starts Google sign-in. A cancelled picker returns to the prior mode.
  Future<void> signInWithGoogle() async {
    final repository = _repository;
    if (repository == null) {
      _setState(
        const AuthState(
          status: AuthStatus.unavailable,
          error:
              'Authentication is not configured. Continue offline to use the journal.',
        ),
      );
      return;
    }

    final previousStatus = _state.status == AuthStatus.offline
        ? AuthStatus.offline
        : AuthStatus.signedOut;
    _setState(
      AuthState(status: previousStatus, user: _state.user, isBusy: true),
    );
    try {
      final user = await repository.signInWithGoogle();
      if (user == null) {
        _setState(AuthState(status: previousStatus));
        return;
      }
      _setState(AuthState(status: AuthStatus.signedIn, user: user));
    } catch (error) {
      _setState(
        AuthState(status: previousStatus, error: _friendlyError(error)),
      );
    }
  }

  /// Signs out only this device while retaining its local Isar data.
  Future<void> signOut() async {
    final repository = _repository;
    if (repository == null) return;
    _setState(
      AuthState(status: _state.status, user: _state.user, isBusy: true),
    );
    try {
      await repository.signOut();
      _setState(const AuthState(status: AuthStatus.signedOut));
    } catch (error) {
      final stillSignedIn = repository.currentUser;
      if (stillSignedIn == null) {
        _setState(const AuthState(status: AuthStatus.signedOut));
      } else {
        _setState(
          AuthState(
            status: AuthStatus.signedIn,
            user: stillSignedIn,
            error: _friendlyError(error),
          ),
        );
      }
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
