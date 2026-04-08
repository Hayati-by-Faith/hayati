import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

class AuthSession {
  const AuthSession({
    required this.uid,
    required this.role,
    required this.isAuthenticated,
  });

  const AuthSession.guest()
      : uid = null,
        role = 'resident',
        isAuthenticated = false;

  final String? uid;
  final String role;
  final bool isAuthenticated;
}

final authSessionProvider = StateProvider<AuthSession>((ref) {
  return const AuthSession.guest();
});
