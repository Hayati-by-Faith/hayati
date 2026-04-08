import 'package:firebase_auth/firebase_auth.dart';

import '../constants/timeout_constants.dart';

class AuthService {
  const AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required PhoneVerificationFailed verificationFailed,
    PhoneVerificationCompleted? verificationCompleted,
    PhoneCodeAutoRetrievalTimeout? codeAutoRetrievalTimeout,
  }) async {
    final completed = verificationCompleted ?? (_) {};
    final timeout = codeAutoRetrievalTimeout ?? (_) {};
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: TimeoutConstants.otpTimeout,
      verificationCompleted: completed,
      verificationFailed: verificationFailed,
      codeSent: (verificationId, _) => codeSent(verificationId),
      codeAutoRetrievalTimeout: timeout,
    );
  }

  Future<UserCredential> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();
}
