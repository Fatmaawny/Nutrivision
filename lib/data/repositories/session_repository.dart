import 'package:shared_preferences/shared_preferences.dart';

import 'package:mealio/data/repositories/auth_repository.dart';

/// Stores the "Remember me" choice (and the email to pre-fill the login form).
/// The password is never stored.
class SessionRepository {
  static const _rememberKey = 'rememberMe';
  static const _emailKey = 'savedEmail';

  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberKey) ?? false;
  }

  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, value);

    // Turning it off forgets the saved email too.
    if (!value) await prefs.remove(_emailKey);
  }

  Future<String> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? '';
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim());
  }

  /// Call once at app start: a signed-in user who did NOT choose
  /// "Remember me" is signed out, so they land on the welcome/login flow.
  Future<void> enforceStartupPolicy(AuthRepository auth) async {
    if (auth.currentUser == null) return;

    if (!await isRememberMeEnabled()) {
      await auth.signOut();
    }
  }
}
