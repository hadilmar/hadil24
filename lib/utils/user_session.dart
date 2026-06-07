import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String guestUserKey = 'guest';

  static Future<String> currentUserKey() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final email = prefs.getString('user_email')?.trim().toLowerCase();

    if (isLoggedIn && email != null && email.isNotEmpty) {
      return email;
    }

    return guestUserKey;
  }
}
