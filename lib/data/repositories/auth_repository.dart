import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// All Firebase Auth calls live here (Views and ViewModels never touch FirebaseAuth).
class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Signs in with email/password.
  ///
  /// On the web the session lifetime follows "Remember me":
  /// LOCAL = stays signed in after closing the browser, SESSION = ends with the tab.
  /// (On Android/iOS the session is always persisted; [SessionRepository]
  /// signs the user out on the next app start when "Remember me" is off.)
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await applyPersistence(rememberMe);

    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Web only: LOCAL keeps the session after closing the browser,
  /// SESSION ends it with the tab. (No-op on Android / iOS.)
  Future<void> applyPersistence(bool rememberMe) async {
    if (!kIsWeb) return;

    try {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    } catch (_) {
      // Persistence could not be changed; the default is used.
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();
}
