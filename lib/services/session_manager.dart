import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; // W razie potrzeby zaimportuj swój model User

///Klasa zarządzająca sesją użytkownika w aplikacji.
///Odpowiada za logowanie, przechowywanie danych sesji oraz wylogowania użytkownika.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }
  /// Prywatny konstruktor wewnętrzny dla Singletona.
  SessionManager._internal();

  // Zmienna przechowująca zalogowanego użytkownika w pamięci
  User? _loggedInUser;

  // Klucz do zapisu nazwy użytkownika w pamięci
  static const String _keyLoggedInUser = 'loggedInUser';

  ///Loguje użytkownika i zapisuje jego nazwę.
  ///
  /// Parametr:
  /// - [user]: Obiekt typu User prezentujący zalogowanego użytkownika
  void login(User user) {
    _loggedInUser = user;
    saveUserToSession(user.username); // Możesz zapisać nazwę użytkownika w pamięci trwałej
  }

  ///Zwraca zalogowanego użytkownika z pamięci.
  ///
  /// Zwraca:
  /// - Obiekt typu User, jeśli użytkownik jest zalogowany, w przeciwnym razie `null`.
  User? getLoggedInUser() {
    return _loggedInUser;
  }

  ///Wylogowuje użytkownika i czyści dane z pamięci.
  void logout() {
    _loggedInUser = null;
    clearSession();
  }

  /// Zapisuje nazwę użytkownika do pamięci trwałej
  ///
  /// Parametr:
  /// - [username]: Nazwa użytkownika do zapisania
  Future<void> saveUserToSession(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoggedInUser, username);
  }

  ///Pobiera zalogowanego użytkownika z pamięci trwałej.
  ///
  /// Zwraca:
  /// - Nazwę użytkownika, jeśli istnieje, w przeciwnym wypadku 'null'
  Future<String?> getLoggedInUserFromSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInUser);
  }

  /// Czyści dane sesji użytkownika z pamięci trwałej.
  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedInUser);
  }
}
