import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:mealio/data/repositories/auth_repository.dart';
import 'package:mealio/data/repositories/session_repository.dart';

/// Result of a login / reset attempt, shown by the View as a snack bar.
class AuthResult {
  final bool success;
  final String? message;
  const AuthResult.ok([this.message]) : success = true;
  const AuthResult.error(this.message) : success = false;
}

/// State + logic of the Login screen, including "Remember me".
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthRepository? auth, SessionRepository? session})
    : _auth = auth ?? AuthRepository(),
      _session = session ?? SessionRepository();

  final AuthRepository _auth;
  final SessionRepository _session;

  bool rememberMe = false;
  bool hidePassword = true;
  bool isLoading = false;

  /// Email to pre-fill when "Remember me" was on (empty otherwise).
  String savedEmail = '';

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Loads the saved "Remember me" choice and the saved email.
  Future<void> init() async {
    rememberMe = await _session.isRememberMeEnabled();
    savedEmail = rememberMe ? await _session.getSavedEmail() : '';
    await _auth.applyPersistence(
      rememberMe,
    ); // also covers Google sign-in on web
    _notify();
  }

  void toggleHidePassword() {
    hidePassword = !hidePassword;
    _notify();
  }

  Future<void> setRememberMe(bool value) async {
    rememberMe = value;
    _notify();
    await _session.setRememberMe(value);
    await _auth.applyPersistence(value);
  }

  /// Keeps the saved email up to date while typing (only if "Remember me" is on).
  Future<void> onEmailChanged(String value) async {
    if (rememberMe) await _session.saveEmail(value);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty || password.isEmpty) {
      return const AuthResult.error('Please enter your email and password');
    }

    isLoading = true;
    _notify();

    try {
      // Save the choice BEFORE signing in, so the startup policy is correct
      // even if the app is closed right after login.
      await _session.setRememberMe(rememberMe);
      if (rememberMe) await _session.saveEmail(cleanEmail);

      await _auth.signInWithEmail(
        email: cleanEmail,
        password: password,
        rememberMe: rememberMe,
      );

      return const AuthResult.ok();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return const AuthResult.error('No account found with this email');
        case 'wrong-password':
        case 'invalid-credential':
          return const AuthResult.error('Incorrect email or password');
        case 'invalid-email':
          return const AuthResult.error('Please enter a valid email address');
        case 'too-many-requests':
          return const AuthResult.error(
            'Too many attempts. Please try again later',
          );
        default:
          return AuthResult.error(e.message ?? 'Login failed');
      }
    } catch (e) {
      return const AuthResult.error('Something went wrong. Please try again');
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<AuthResult> resetPassword(String email) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      return const AuthResult.error('Enter your email address first');
    }

    try {
      await _auth.sendPasswordReset(cleanEmail);
      return const AuthResult.ok('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(e.message ?? 'Could not send reset email');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
