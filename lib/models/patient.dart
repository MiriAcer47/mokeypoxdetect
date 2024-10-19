///Klara reprezentująca pacjenta.
class Patient {
  ///unikalny identyfikator pacjenta.
  int? patientID;

  ///Imię pacjenta.
  String firstName;

  ///Nazwisko pacjenta.
  String secondName;

  ///Płeć pacjenta.
  String gender;

  ///Data urodzenia pacjenta: 'M' dla mężczyzna, 'K' dla kobiety.
  DateTime birthDate;

  ///Numer telefonu pacjenta (opcjonalny).
  String? telNo;

  ///Email pacjenta (opcjonalny).
  String? email;

  ///Pesel pacjenta (opcjonalny).
  String? pesel;

  /// Konstruktor klasy Patient.
  ///
  /// Parametry:
  /// - [patientID]: ID pacjenta.
  /// - [firstName]: Imię pacjenta.
  /// - [secondName]: Nazwisko pacjenta.
  /// - [gender]: Płeć pacjenta.
  /// - [birthDate]: Data urodzenia pacjenta.
  /// - [telNo]: Numer telefonu pacjenta.
  /// - [email]: Email pacjenta.
  /// - [pesel]: PESEL pacjenta.
  Patient({
    this.patientID,
    required this.firstName,
    required this.secondName,
    required this.gender,
    required this.birthDate,
    this.telNo,
    this.email,
    this.pesel,
  });

  ///Konwersja obiektu Patient na mapę do zapisu w bazie danych.
  ///
  /// Zwraca:
  /// - Mapę z danymi pacjenta.
  Map<String, dynamic> toMap() {
    final map = {
      'firstName': firstName,
      'secondName': secondName,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'telNo': telNo,
      'email': email,
      'pesel': pesel?.isEmpty == true ? null : pesel,
    };
    if (patientID != null) {
      map['patientID'] = patientID as String?;
    }
    return map;
  }

  ///Tworzy obiektu Patient na podstawie mapy pobranej z bazy danych.
  ///
  /// Parametr:
  /// - [map]: Mapa zawierająca dane pacjenta.
  ///
  /// Zwraca:
  /// - Obiekt typu Patient.
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientID: map['patientID'] as int?,
      firstName: map['firstName'] as String,
      secondName: map['secondName'] as String,
      gender: map['gender'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      telNo: map['telNo'] as String?,
      email: map['email'] as String?,
      pesel: map['pesel'] as String?,
    );
  }
}
