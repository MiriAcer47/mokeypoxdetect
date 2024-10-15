///Klasa reprezentująca obraz robiony w ramach badania.
class ExaminationImage {
  ///Unikalny identyfkator obrazu.
  int? imageID;

  ///Wynik dla obrazu: true - pozytywny, false - negatywny
  bool? result;

  ///ID badania, w ramach którego wykonywane jest zdjęcie.
  int examinationID;

  ///Ścieżka do pliku obrazu.
  String imgPath;

  /// Parametry:
  /// - [imageID]: ID obrazu.
  /// - [result]: Wynik związany z obrazem.
  /// - [examinationID]: ID badania.
  /// - [imgPath]: Ścieżka do obrazu.
  ExaminationImage({
    this.imageID,
    this.result,
    required this.examinationID,
    required this.imgPath,
  });

  ///Konwersja obiektu ExamintionImage na mapę do zapisania w bazie danych.
  ///
  ///Zwraca:
  /// - Mapę z danymi obrazu badania.
  Map<String, dynamic> toMap() {
    return {
      'imageID': imageID,
      'result': result == null ? null : (result! ? 1 : 0),
      'examinationID': examinationID,
      'imgPath': imgPath,
    };
  }
  ///Tworzy obiekt Examination Image na podstawie mapy pobranej z bazy danych.
  ///
  /// Parametr:
  /// - [map]: Mapa zawierająca dane obrazu badania.
  ///
  /// Zwraca:
  /// Obiekt typu ExaminationImage.
  factory ExaminationImage.fromMap(Map<String, dynamic> map) {
    return ExaminationImage(
      imageID: map['imageID'] as int?,
      result: map['result'] != null ? (map['result'] == 1) : null,
      examinationID: map['examinationID'] as int,
      imgPath: map['imgPath'] as String,
    );
  }
}
