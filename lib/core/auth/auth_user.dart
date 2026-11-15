import 'package:flutter/foundation.dart';

/// Profile details made available by the authentication provider.
@immutable
class AuthUser {
  const AuthUser({required this.id, this.name, this.email, this.avatarUrl});

  /// Stable Supabase user ID used to select the local Isar database.
  final String id;

  /// Name supplied by the Google profile, when available.
  final String? name;

  /// Email supplied by the Google profile, when available.
  final String? email;

  /// Avatar URL supplied by the Google profile, when available.
  final String? avatarUrl;
}
