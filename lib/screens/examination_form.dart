import 'package:flutter/material.dart';
import 'package:monkey/styles.dart';
import '../models/patient.dart';
import '../models/examination.dart';
import '../models/examination_image.dart';
import 'examination_image_form_tl.dart';
import 'package:image_picker/image_picker.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'alertDialog.dart';

/// Klasa przedstawiająca formularz dodawania lub edycji badania pacjenta.
///
/// Umożliwia użytkownikowi wprowadzenie lub edycję informacji o badaniu.
/// Po zapisaniu danych użytkownik zostaje przekierowany do listy z badaniami pacjenta.
class ExaminationForm extends StatefulWidget {
  /// Pacjent, do którego przypisane jest badanie.
  final Patient patient;

  /// Obiekt 'Examination' do edycji. Jeśli jest 'null', formularz służy do dodawania nowego badania.
  Examination? examination;

  /// Konstruktor klasy 'ExaminationForm'
  ///
  /// Parametry:
  /// - [patient]: Obiekt pacjenta, dla którego tworzone lub edytowane jest badanie.
  /// - [examination]: Opcjonalny obieky badania do edycji.
  ExaminationForm({super.key, required this.patient, this.examination});

  @override
  _ExaminationFormState createState() => _ExaminationFormState();
}

class _ExaminationFormState extends State<ExaminationForm> {
  /// Klucz formularza do zarządzania walidacją.
  final _formKey = GlobalKey<FormState>();

  /// Instancja klasy 'DatabaseHelper' do interakcji z bazą danych.
  final dbHelper = DatabaseHelper.instance;

  /// Data badania.
  late DateTime _date;

  /// Wynik końcowy badania (true - pozytywny, false - negatywny)
  bool? _finalResult;

  /// Notatki związane z badaniem.
  String? _notes;

  /// Lista zdjęć związanych z badaniem.
  List<ExaminationImage> images = [];

  /// Flaga informująca o trakcie zapisywania badania.
  bool _isSaving = false;

  /// Metoda wywoływana podczas inicjalizacji stanu.
  ///
  /// Ustawia początkowe wartości pól formularza na podstawie przekazanego obiektu badania lub ustawia domyślne wartości dla nowego badania.
  @override
  void initState() {
    super.initState();
    if (widget.examination != null) {
      _date = widget.examination!.date;
      _finalResult = widget.examination!.finalResult;
      _notes = widget.examination!.notes;
      _loadImages();
    } else {
      _date = DateTime.now();
      _finalResult = false;
      _notes = '';
    }
  }

  /// Ładuje zdjęcie związane z badaniam z bazy danych.
  ///
  /// Jeśli badanie istnieje, pobiera listę zdjęć dla tego badania z bazy.
  Future<void> _loadImages() async {
    if (widget.examination != null && widget.examination!.examinationID != null) {
      images = await dbHelper.getExaminationImages(widget.examination!.examinationID!);
      setState(() {});
    }
  }

  /// Usuwa zdjęcie z badania na podstawie jego ID.
  ///
  /// Parametr:
  /// - [imageID]: ID zdjęcia do usunięcia.
  ///
  /// Po usunięciu zdjęcia, odswieża listę zdjęć.
  void _deleteImage(int imageID) async {
    await dbHelper.deleteExaminationImage(imageID);
    _loadImages();
  }

  /// Zapisuje badanie do bazy danych.
  ///
  /// Jeśli badanie jest nowe, dodaje je do bazy. W przeciwnym razie, aktualizuje istniejący rekord.
  /// Po zapisaniu, przekierowuje użytkownika z powrotem do listy badań pacjenta.
  Future<void> _saveExamination({bool showSnackbar = true}) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });

      final exam = Examination(
        examinationID: widget.examination?.examinationID,
        patientID: widget.patient.patientID!,
        date: _date,
        finalResult: _finalResult,
        notes: _notes,
      );

      try {
        if (widget.examination == null) {
          // Dodawanie nowego badania
          int newId = await dbHelper.insertExamination(exam);
          // Aktualizacja Examination w widgetcie
          widget.examination = Examination(
            examinationID: newId,
            patientID: widget.patient.patientID!,
            date: _date,
            finalResult: _finalResult!,
            notes: _notes,
          );
          print("New examination added successfully with ID: $newId.");
        } else {
          // Aktualizacja istniejącego badania
          await dbHelper.updateExamination(exam);
          print("Examination updated successfully.");
        }

        if (showSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Examination saved successfully.')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Obsługa błędów przy zapisywaniu
        print('Error saving examination: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Error saving examination. Please try again.')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Metoda wywoływana przy wyborze daty badania w kalendarzu.
  ///
  /// Parametr:
  /// - [context]: Kontekst aplikacji.
  ///
  /// Aktualizuje datę badania, jeśli użytkownik wybierze nową datę.
  Future<void> _selectExaminationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Zastosowanie motywu do DatePicker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary, // Kolor nagłówka
              onPrimary: Theme.of(context).colorScheme.onPrimary, // Kolor tekstu nagłówka
              surface: Theme.of(context).colorScheme.surface, // Tło DatePicker
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // Kolor przycisków
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  /// Wyświetla okno dialogowe potwierdzające usunięcie zdjęcia z badania.
  ///
  /// Parametr:
  /// - [id]: ID zdjęcia do usunięcia.
  void _confirmDeleteImage(int id) {
    CCupertinoAlertDialog.show(
      context: context,
      title: "Delete photo.",
      content: 'Are you sure you want to delete this photo?',
      onConfirm: () {
        _deleteImage(id);
      },
    );
  }

  /// Nawiguje do ekrany dodawania zdjęcia.
  ///
  /// Parametr:
  /// - [typ]: Typ zdjęcia (1: take photo, 2: select from gallery)
  Future<void> _navigateToImageForm(int typ) async {
    // Sprawdzenie, czy badanie jest zapisane
    if (widget.examination == null || widget.examination!.examinationID == null) {
      // Jeśli badanie nie jest zapisane, zapisz je automatycznie
      await _saveExamination(showSnackbar: false);
      if (widget.examination == null || widget.examination!.examinationID == null) {
        // Jeśli zapisanie się nie powiodło, przerwij akcję
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot add a photo without a saved exam.')),
        );
        return;
      }
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExaminationImageFormTL(examination: widget.examination!, typ: typ,),
      ),
    );
    _loadImages();
  }

  /// Buduje interfejs użytkownika formularza badania pacjenta.
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Sprawdzenie, czy badanie jest zapisane
    bool isSaved =
        widget.examination != null && widget.examination!.examinationID != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.examination == null ? 'Add Examination' : 'Edit Examination',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: colorScheme.surface, // Kolor tła karty
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Pole wyboru daty badania.
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(Icons.calendar_today,
                                color: colorScheme.primary),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        controller: TextEditingController(
                          text: dateFormat.format(_date),
                        ),
                        onTap: () => _selectExaminationDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a date.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      /// Przełącznik wyboru wyniku końcowego badania.
                      Text(
                        'Final Result',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(10),
                        isSelected: [
                          _finalResult == true,
                          _finalResult == false
                        ],
                        onPressed: (int index) {
                          setState(() {
                            _finalResult = index == 0;
                          });
                        },
                        //colorScheme.error : Colors.green.shade400
                        selectedColor: colorScheme.onPrimary,
                        color: colorScheme.primary,
                        fillColor: _finalResult == true ? colorScheme.error.withOpacity(0.7) : Colors.green.shade400.withOpacity(0.7), // Zwiększona przejrzystość
                        borderColor: colorScheme.primary, // Dodanie koloru obramowania
                        selectedBorderColor: colorScheme.primary, // Kolor obramowania, gdy wybrane
                        constraints: BoxConstraints(
                          minHeight: 40.0,
                          minWidth: MediaQuery.of(context).size.width * 0.4,
                        ),
                        children: const [
                          Text('Positive'),
                          Text('Negative'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// Pole tekstowe do wpisywania notatek.
                      TextFormField(
                        initialValue: _notes,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          prefixIcon:
                          Icon(Icons.note, color: colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        onSaved: (value) => _notes = value,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Wyświetlanie zdjęć związanych z badaniem.
                      Text(
                        'Photos',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      images.isEmpty
                          ? Center(
                        child: Text(
                          'No photos added.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final img = images[index];
                          return Card(
                            margin:
                            const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(12.0),
                                child: Image.file(
                                  File(img.imgPath),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                'Result: ${img.result == true ? 'Positive' : 'Negative'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: img.result == true
                                      ? colorScheme.error
                                      : Colors.green.shade400,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete,
                                    color: colorScheme.error),
                                onPressed: () =>
                                    _confirmDeleteImage(img.imageID!),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // Umieszczenie przycisków w bottomNavigationBar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            /// Przycisk Save
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                  await _saveExamination();
                },
                icon: Icon(Icons.save, color: colorScheme.onPrimary),
                label: Text(
                  'Save',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isSaving ? 0 : 5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            /// Przycisk Take Photo.
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                  // Automatyczne zapisanie badania, jeśli nie jest zapisane
                  if (!isSaved) {
                    await _saveExamination(showSnackbar: false);
                    // Sprawdzenie, czy zapisanie się powiodło
                    if (widget.examination == null ||
                        widget.examination!.examinationID == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Cannot add a photo without a saved study.')),
                      );
                      return;
                    }
                  }
                  // Przejście do formularza dodawania zdjęcia
                  await _navigateToImageForm(1);
                },
                icon: Icon(Icons.add_a_photo, color: colorScheme.onPrimary),
                label: Text(
                  'Take',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(width: 8),

            /// Przycisk Add Photo.
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                  // Automatyczne zapisanie badania, jeśli nie jest zapisane
                  if (!isSaved) {
                    await _saveExamination(showSnackbar: false);
                    // Sprawdzenie, czy zapisanie się powiodło
                    if (widget.examination == null ||
                        widget.examination!.examinationID == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Cannot add a photo without a saved study.')),
                      );
                      return;
                    }
                  }
                  // Przejście do formularza dodawania zdjęcia
                  await _navigateToImageForm(2);
                },
                icon: Icon(Icons.photo_library, color: colorScheme.onPrimary),
                label: Text(
                  'Add',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5   ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
