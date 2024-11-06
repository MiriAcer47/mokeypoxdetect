/// Klasa reprezentująca użytkownika systemu.
class User {
  ///Unikalny identyfikator użytkownika.
  int? userID;

  ///Nazwa użytkownika.
  String username;

  ///PIN użytkownika.
  String pin;

  ///Email użytkownika.
  String email;

  ///Status administracyjny użytkownika.
  bool isAdmin;

  ///Status blokady konta użytkownika.
  bool isBlocked;


  /// Konstruktor klasy User.
  ///
  /// Parametry:
  /// - [userID]: ID użytkownika.
  /// - [username]: Nazwa użytkownika.
  /// - [pin]: PIN użytkownika.
  /// - [email]: Email użytkownika.
  /// - [isAdmin]: Czy użytkownik ma status administratora (domyślnie `false`).
  /// - [isBlocked]: Czy konto użytkownika jest zablokowane (domyślnie `false`).
  User({
    this.userID,
    required this.username,
    required this.pin,
    required this.email,
    this.isAdmin = false,
    this.isBlocked = false,
  });

  ///Konwersja obiektu User na mapę do zapisu w bazie danych.
  ///
  /// Zwraca:
  /// - Mapę z danymi użytkownika.
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'username': username,
      'pin': pin,
      'email': email,
      'isAdmin': isAdmin ? 1 : 0,  // Zapisujemy bool jako int
      'isBlocked': isBlocked ? 1 : 0,  // Zapisujemy bool jako int
    };
  }
  /// Tworzy obiekt User na podstawie mapy pobranej z bazy danych.
  ///
  /// Parametr:
  /// - [map]: Mapa zawierająca dane użytkownika.
  ///
  /// Zwraca:
  /// - Obiekt typu User.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userID: map['userID'] as int?,
      username: map['username'] as String,
      pin: map['pin'] as String,
      email: map['email'] as String,
      isAdmin: map['isAdmin'] == 1,
      isBlocked: map['isBlocked'] == 1,
    );
  }
}
