import 'dart:io';
import 'package:flutter/material.dart';
import '../models/examination.dart';
import '../models/examination_image.dart';
import '../database_helper.dart';
import 'examination_image_form.dart';
import 'examination_image_form_tl.dart';
import 'alertDialog.dart';

/// Klasa przedstawiająca listę zdjęć dla badania.
///
/// Pozwala użytkownikowi na przegladanie oraz usuwanie zdjęć dla danego badania.
/// Każde zdjęcie jest wyświetlane wraz z informacją o wyniku klasyfikacji.
class ExaminationImageList extends StatefulWidget {
  /// Badanie, dla którego wyświetlane są zdjęcia.
  final Examination examination;

  ///Konstruktor klasy 'ExaminationImageList'
  ///
  /// Parametr:
  /// - [examination]: Obiekt badania, którego zdjęcia są wyświetlane.
  const ExaminationImageList({super.key, required this.examination});

  @override
  _ExaminationImageListState createState() => _ExaminationImageListState();
}

class _ExaminationImageListState extends State<ExaminationImageList> {
  /// Lista zdjęć dla danego badania.
  List<ExaminationImage> images = [];

  /// Instancja klasy 'DatabaseHelper' do interakcji z bazą danych.
  final dbHelper = DatabaseHelper.instance;


  /// Metoda wywoływana podczas inicjalizacji stanu.
  ///
  /// Pobiera listę zdjęć z bazy danych.
  @override
  void initState() {
    super.initState();
    _refreshImages();
  }

  /// Metoda pobierania zdjęć z bazy danych.
  ///
  /// Pobiera wszystkie zdjęcia związane z danym badaniem i aktualizuje stan widgetu.
  void _refreshImages() async {
    images = await dbHelper.getExaminationImages(widget.examination.examinationID!);
    setState(() {});
  }
  ///Metoda usuwania zdjęcia z bazy danych na podstawie jego ID.
  ///
  /// Parametr:
  /// - [id]: ID zdjęcia do usunięcia
  /// Po usunięciu zdjęcia odświeża listę zdjęć.
  void _deleteImage(int id) async {
    await dbHelper.deleteExaminationImage(id);
    _refreshImages();
  }

  /// Przejście do formularza robienia zdjęcia
  ///
  /// Po powrocie z dormularza, odświeża listę zdjęć.
  void _navigateToImageForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExaminationImageFormTL(examination: widget.examination, typ: 1,),
      ),
    );
    _refreshImages();
  }

  /// WYświetla okno dialogowe potwierdzające usunięcie zdjęcia.
  ///
  /// Parametr:
  /// - [id]: ID zdjęcia do usunięcia.
  void _confirmDeleteImage(int id){
    CCupertinoAlertDialog.show(
      context: context,
      title: "Delete Image",
      content: 'Do you really want to delete this image?',
      onConfirm: (){
        _deleteImage(id);
      },
    );
  }

  /// Buduje interfejs użytkownika listy zdjęć dla danego badania.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examination Images'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final img = images[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading:ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(img.imgPath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  'Result: ${img.result == true ? 'Positive' : 'Negative'}',
                  style: const TextStyle(
                    fontSize: 18,
                    //fontWeight: FontWeight.bold,
                    //color: img.result == true ? Colors.red : Colors.green,
                  ),),
                trailing: IconButton(
                  //Przycisk usuwania zdjęcia
                  icon: const Icon(Icons.delete, color: Colors.red),
                  //onPressed: () => _deleteImage(img.imageID!),
                  onPressed: () => _confirmDeleteImage(img.imageID!),
                ),
              ),
            );
          },
        ),
      ),
      //Przycisk dodawania nowego zdjęcia
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToImageForm(),
        label: const Text('Take a photo'),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}