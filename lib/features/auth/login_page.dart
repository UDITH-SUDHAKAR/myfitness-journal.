import 'package:flutter/material.dart';

import '../../core/auth/auth_controller.dart';

/// Offers Google sign-in or direct access to the local-only journal.
class LoginPage extends StatelessWidget {
  const LoginPage({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fitness_center, size: 52),
                    const SizedBox(height: 16),
                    Text(
                      'Myfitness Journal',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to keep a separate journal for your account, '
                      'or continue with data stored on this device.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        key: const ValueKey('authentication-error'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    if (state.status == AuthStatus.unavailable) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Google sign-in is not configured. Offline access is available.',
                        textAlign: TextAlign.center,
                        key: ValueKey('authentication-unavailable'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('google-sign-in'),
                        onPressed:
                            state.isBusy ||
                                state.status == AuthStatus.unavailable
                            ? null
                            : controller.signInWithGoogle,
                        icon: state.isBusy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                          state.isBusy
                              ? 'Signing in...'
                              : 'Continue with Google',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        key: const ValueKey('continue-offline'),
                        onPressed: state.isBusy
                            ? null
                            : controller.continueOffline,
                        child: const Text('Continue Offline'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
