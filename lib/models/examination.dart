///Klasa repezentująca badanie pacjenta.
class Examination {
  ///Unikalny identyfikator badania.
  int? examinationID;

  ///ID pacjenta, któremu jest robione badanie.
  int patientID;

  ///Data wykonania badania.
  DateTime date;

  ///Ostateczny wynik badania: true - pozytywny, false - negatywny.
  bool? finalResult;

  ///Notatki z badania.
  String? notes;

  ///Konstruktor klasy Examination.
  ///
  /// Parametry:
  /// - [examinationID]: ID badania.
  /// - [patientID]: ID pacjenta.
  /// - [date]: Data wykonania badania.
  /// - [finalResult]: Ostateczny wynik badania.
  /// - [notes]: Notatki z badania.
  Examination({
    this.examinationID,
    required this.patientID,
    required this.date,
    this.finalResult,
    this.notes,
  });

  ///Konwersja obiektu Examination na mapę do zapisania w bazie danych.
  ///
  /// Zwraca:
  /// - Mapa z danymi badania.
  Map<String, dynamic> toMap() {
    return {
      'examinationID': examinationID,
      'patientID': patientID,
      'date': date.toIso8601String(),
      'finalResult': finalResult == null ? null : (finalResult! ? 1 : 0),
      'notes': notes,
    };
  }

 ///Tworzy obiekt Examination na podstawie mapy pobranej z bazy danych.
  ///
  /// Parametr:
  /// - [map]: Mapa zawierająca dane badania.
  ///
  /// Zwraca:
  /// - Obiekt typu Examination.
  factory Examination.fromMap(Map<String, dynamic> map) {
    return Examination(
      examinationID: map['examinationID'] as int?,
      patientID: map['patientID'] as int,
      date: DateTime.parse(map['date'] as String),
      finalResult: map['finalResult'] != null ? (map['finalResult'] == 1) : null,
      notes: map['notes'] as String?,
    );
  }
}
