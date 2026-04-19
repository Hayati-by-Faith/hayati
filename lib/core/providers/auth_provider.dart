import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/business_constants.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

class AuthSession {
  const AuthSession({
    required this.uid,
    required this.role,
    required this.isAuthenticated,
  });

  const AuthSession.guest()
      : uid = null,
        role = BusinessConstants.defaultRole,
        isAuthenticated = false;

  final String? uid;
  final String role;
  final bool isAuthenticated;
}

final authSessionProvider = Provider<AuthSession>((ref) {
  final user = ref.watch(authStateChangesProvider).asData?.value ??
      FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const AuthSession.guest();
  }
  return AuthSession(
    uid: user.uid,
    role: BusinessConstants.defaultRole,
    isAuthenticated: true,
  );
});
