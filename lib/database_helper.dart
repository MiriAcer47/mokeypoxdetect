import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/patient.dart';
import 'models/examination.dart';
import 'models/examination_image.dart';
import 'models/user.dart';

///Klasa do obsługi bazy danych SQLite w aplikacji.
class DatabaseHelper {
  ///Singleton instancji DatabaseHelper.
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  ///Prywatna instancja bazy danych.
  static Database? _database;

  ///Konstruktor klasy DatabaseHelper.
  DatabaseHelper._privateConstructor();

  ///Getter dla bazy danych.
  ///Inicjallizacje bazę danych, jeśli nie została jeszcze zainicjalizowana.
  Future<Database> get database async => _database ??= await _initDatabase();

  ///Inicjalizacja bazy danych.
  ///Tworzy plik bazy danych w katalogu aplikacji i ustawia parametry bazy.
  Future<Database> _initDatabase() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    String path = join(docsDir.path, 'patients.db');
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    await db.execute('PRAGMA foreign_keys = ON');
    return db;
  }

  ///Metoda wywołana podczas tworzenia bazy danych.
  ///Tworzy tabele i wstawia dane początkowe.
  ///
  /// Parametry:
  ///  - [db]: Obiekt bazy danych.
  ///  - [version]: Wersja bazy danych.
  Future _onCreate(Database db, int version) async {
    //Definicja tabeli Patient w bazie danych.
    await db.execute(''' 
      CREATE TABLE Patient (
        patientID INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName VARCHAR(20) NOT NULL,
        secondName VARCHAR(50) NOT NULL,
        gender VARCHAR(1) NOT NULL,
        birthDate TEXT NOT NULL,
        telNo VARCHAR(50),
        email VARCHAR(50),
        pesel VARCHAR(20) UNIQUE NULL
      )
    ''');
    //Definicja tabeli Examination w bazie danych.
    await db.execute('''
      CREATE TABLE Examination (
        examinationID INTEGER PRIMARY KEY AUTOINCREMENT,
        patientID INTEGER,
        date TEXT NOT NULL,
        finalResult INTEGER,
        notes VARCHAR(255),
        FOREIGN KEY (patientID) REFERENCES Patient(patientID) ON DELETE CASCADE
      )
    ''');

    //Definicja tabeli ExaminationImage w bazie danych.
    await db.execute('''
      CREATE TABLE ExaminationImage (
        imageID INTEGER PRIMARY KEY AUTOINCREMENT,
        result INTEGER,
        examinationID INTEGER,
        imgPath VARCHAR(255) NOT NULL,
        FOREIGN KEY (examinationID) REFERENCES Examination(examinationID) ON DELETE CASCADE
      )
    ''');

    //Definicja tabeli User w bazie danych.
    await db.execute('''
      CREATE TABLE User (
        userID INTEGER PRIMARY KEY AUTOINCREMENT,
        username VARCHAR(20) NOT NULL UNIQUE,
        pin VARCHAR(5) NOT NULL,
        email VARCHAR(50) NOT NULL UNIQUE
      )
    ''');

    // Wstawienie domyślnego użytkownika
    await db.insert('User', {
      'username': 'admin',
      'pin': '1234',
      'email': 'admin@example.com',
    });
  }

  //Metody dla tabeli User

  ///Wstawia nowego użytkownika do bazy danych.
  ///
  /// Parametr:
  /// - [user]: Obiekt typu User do wstawienia.
  ///
  /// Zwraca:
  /// - ID wstawionego rekordu.
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert('User', user.toMap());
  }

  ///Pobiera użytkownika na podstawie nazwy użytkownika.
  ///
  /// Paramet:
  /// - [username]: Nazwa użytkownika do wyszukiwania.
  ///
  /// Zwraca:
  /// Obiekt typu User, jeśli znaleziono, w przeciwnym razie 'null'.
  Future<User?> getUser(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      'User',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }
 ///Aktualizuje dane użytkownika w bazie danych.
  ///
  /// Parametr:
  /// - [user]: Obiekt typu User z zaktualizowanymi danymi.
  ///
  /// Zwraca:
  ///  - Liczbę zaktualizowanych rekordów.
  Future<int> updateUser(User user) async {
    Database db = await instance.database;
    return await db.update(
      'User',
      user.toMap(),
      where: 'userID = ?',
      whereArgs: [user.userID],
    );
  }
  ///Usuwa użytkownika z bazy danych na podstawie ID.
  ///
  /// Parametr:
  /// - [userID]: ID użytkownika.
  ///
  /// Zwraca:
  /// - Liczbę usuniętych rekordów.
  Future<int> deleteUser(int userID) async {
    Database db = await instance.database;
    return await db.delete(
      'User',
      where: 'userID = ?',
      whereArgs: [userID],
    );
  }

  //Metody dla tabeli Patient

  ///Wstawia nowego pacjenta do bazy danych.
  ///
  /// Parametr:
  /// - [patient]: Obiekt typu Patient do wstawienia.
  ///
  /// Zwraca:
  /// - ID wstawionego rekordu.
  Future<int> insertPatient(Patient patient) async {
    Database db = await instance.database;
    return await db.insert('Patient', patient.toMap());
  }
  ///Pobiera listę wszystkich pacjentów z bazy.
  ///
  /// Zwraca:
  /// - Listę obiektów typu Patient.
  Future<List<Patient>> getPatients() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('Patient');
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  ///Aktualizuję danę pacjenta w bazie danych.
  ///
  /// Parametr:
  /// - [patient]: Obiekt typu Patient z zaktualizowanyi danymi.
  ///
  /// Zwraca:
  /// - Liczbę zaktualizowanych rekordów.
  Future<int> updatePatient(Patient patient) async {
    Database db = await instance.database;
    return await db.update(
      'Patient',
      patient.toMap(),
      where: 'patientID = ?',
      whereArgs: [patient.patientID],
    );
  }
 ///Usuwa pacjenta z bazy danych na podstawie ID.
  ///
  /// Parametr:
  /// - [id]: ID pacjenta do usunięcia.
  ///
  /// Zwraca:
  ///  - Liczbę usuniętych rekordów.
  Future<int> deletePatient(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'Patient',
      where: 'patientID = ?',
      whereArgs: [id],
    );
  }

  //Metody dla tabeli Examination

  ///Wstawia nowe badanie do bazy danych.
  ///
  /// Parametr:
  /// - [exam]: Obiekt typu Examination do wstawienia.
  ///
  /// Zwraca:
  /// - ID wstawionego rekordu.
  Future<int> insertExamination(Examination exam) async {
    Database db = await instance.database;
    return await db.insert('Examination', exam.toMap());
  }

  ///Pobiera listę badań dla danego pacjenta na podstawie jego ID.
  ///
  /// Parametr:
  /// - [patientID]: ID pacjenta, dla którego mają zostać pobrane badania.
  ///
  /// Zwraca:
  /// - Listę obiektów typu Examination.
  Future<List<Examination>> getExaminations(int patientID) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Examination',
      where: 'patientID = ?',
      whereArgs: [patientID],
    );
    return List.generate(maps.length, (i) => Examination.fromMap(maps[i]));
  }

  ///Aktualuję dane badania w bazie danych.
  ///
  /// Parametr:
  /// - [exam]: obiekt typu Examination z zaktualizowanymi danymi.
  ///
  /// Zwraca:
  /// - Liczbę zaktualizowanych rekordów.
  Future<int> updateExamination(Examination exam) async {
    Database db = await instance.database;
    return await db.update(
      'Examination',
      exam.toMap(),
      where: 'examinationID = ?',
      whereArgs: [exam.examinationID],
    );
  }

  ///Usuwanie badanie z bazy danych na podstawie ID.
  ///
  /// Parametr:
  /// - [id]: ID badania do usunięcia.
  ///
  /// Zwraca:
  /// - Liczbę usuniętych rekordów
  Future<int> deleteExamination(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'Examination',
      where: 'examinationID = ?',
      whereArgs: [id],
    );
  }

  // Metody dla tabeli ExaminationImage

  ///Wstawia nowy obraz badania do bazy danych.
  ///
  /// Parametr:
  /// - [image]: Obiekt typu ExaminationImage do wstawienia.
  ///
  /// Zwraca:
  /// - ID wstawionego rekordu.
  Future<int> insertExaminationImage(ExaminationImage image) async {
    Database db = await instance.database;
    return await db.insert('ExaminationImage', image.toMap());
  }
  ///Pobiera listę obrazów dla danego badania na podstawie ID badania.
  ///
  /// Parametr:
  /// - [examinationID]: ID badania, dla którego mają zostać pobrane obrazy.
  ///
  /// Zwraca:
  /// - Listę obiektów typu ExaminationImage.
  Future<List<ExaminationImage>> getExaminationImages(int examinationID) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ExaminationImage',
      where: 'examinationID = ?',
      whereArgs: [examinationID],
    );
    return List.generate(maps.length, (i) => ExaminationImage.fromMap(maps[i]));
  }

  ///Usuwa obraz badania z bazy danych na podstawie ID.
  ///
  /// Parametr:
  /// - [id]: ID obrazu do usunięcia.
  ///
  /// Zwraca:
  /// - Liczbę usuniętych rekordów.
  Future<int> deleteExaminationImage(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'ExaminationImage',
      where: 'imageID = ?',
      whereArgs: [id],
    );
  }
}
