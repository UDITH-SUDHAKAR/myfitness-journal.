import 'package:flutter/material.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_user.dart';

/// Displays the signed-in Google profile or the current offline mode.
class AccountDialog extends StatelessWidget {
  const AccountDialog({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final user = controller.state.user;
        return AlertDialog(
          title: Text(user == null ? 'Offline journal' : 'Account'),
          content: user == null
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(child: Icon(Icons.phone_android)),
                    SizedBox(height: 12),
                    Text(
                      'Your data is stored in the offline journal on this device.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : _ProfileDetails(user: user),
          actions: [
            if (controller.state.error != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  controller.state.error!,
                  key: const ValueKey('account-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            TextButton(
              onPressed: controller.state.isBusy
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (user == null)
              FilledButton.icon(
                key: const ValueKey('account-sign-in'),
                onPressed: controller.state.isBusy
                    ? null
                    : () async {
                        await controller.signInWithGoogle();
                        if (context.mounted &&
                            controller.state.status == AuthStatus.signedIn) {
                          Navigator.of(context).pop();
                        }
                      },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
              )
            else
              FilledButton.tonal(
                key: const ValueKey('account-sign-out'),
                onPressed: controller.state.isBusy
                    ? null
                    : () async {
                        await controller.signOut();
                        if (context.mounted &&
                            controller.state.status == AuthStatus.signedOut) {
                          Navigator.of(context).pop();
                        }
                      },
                child: const Text('Sign out'),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 32,
          child: avatarUrl == null
              ? const Icon(Icons.person, size: 32)
              : ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 32),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Text(user.name ?? 'Google account'),
        if (user.email != null) ...[
          const SizedBox(height: 4),
          Text(user.email!, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
