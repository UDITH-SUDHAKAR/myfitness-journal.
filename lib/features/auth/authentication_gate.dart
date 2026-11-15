import 'package:flutter/material.dart';

import '../../core/auth/auth_controller.dart';
import 'login_page.dart';

/// Chooses the login screen or a journal built for the active local identity.
class AuthenticationGate extends StatelessWidget {
  const AuthenticationGate({
    required this.controller,
    required this.journalBuilder,
    super.key,
  });

  final AuthController controller;

  /// Builds a journal for a Supabase user ID, or the offline store when null.
  final Future<Widget> Function(String? userId) journalBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        if (state.status == AuthStatus.initializing) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Restoring your session...'),
                ],
              ),
            ),
          );
        }

        if (state.status == AuthStatus.signedIn ||
            state.status == AuthStatus.offline) {
          final userId = state.status == AuthStatus.signedIn
              ? state.user!.id
              : null;
          return _JournalScopeLoader(
            key: ValueKey(userId ?? 'offline-journal'),
            userId: userId,
            builder: journalBuilder,
          );
        }

        return LoginPage(controller: controller);
      },
    );
  }
}

class _JournalScopeLoader extends StatefulWidget {
  const _JournalScopeLoader({
    required this.userId,
    required this.builder,
    super.key,
  });

  final String? userId;
  final Future<Widget> Function(String? userId) builder;

  @override
  State<_JournalScopeLoader> createState() => _JournalScopeLoaderState();
}

class _JournalScopeLoaderState extends State<_JournalScopeLoader> {
  late Future<Widget> _journalFuture;

  @override
  void initState() {
    super.initState();
    _openJournal();
  }

  void _openJournal() {
    _journalFuture = widget.builder(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _journalFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not open this local journal.'),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(_openJournal),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Opening your local journal...'),
                ],
              ),
            ),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
