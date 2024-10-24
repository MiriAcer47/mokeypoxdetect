import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; // W razie potrzeby zaimportuj swój model User

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  User? _loggedInUser; // Użytkownik trzymany w pamięci

  static const String _keyLoggedInUser = 'loggedInUser';

  // Setter i getter dla zalogowanego użytkownika
  void login(User user) {
    _loggedInUser = user;
    saveUserToSession(user.username); // Możesz zapisać nazwę użytkownika w pamięci trwałej
  }

  User? getLoggedInUser() {
    return _loggedInUser;
  }

  void logout() {
    _loggedInUser = null;
    clearSession(); // Czyścimy pamięć trwałą
  }

  // Przechowywanie sesji w pamięci trwałej (SharedPreferences)
  Future<void> saveUserToSession(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoggedInUser, username);
  }

  Future<String?> getLoggedInUserFromSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInUser);
  }

  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedInUser);
  }
}
