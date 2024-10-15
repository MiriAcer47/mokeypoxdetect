import 'dart:io';
import 'package:flutter/material.dart';
import '../models/examination.dart';
import '../models/examination_image.dart';
import '../database_helper.dart';
import 'examination_image_form.dart';
import 'alertDialog.dart';

//Klasa przedstawiająca listę zdjęć dla badania
class ExaminationImageList extends StatefulWidget {
  final Examination examination;

  ExaminationImageList({required this.examination});

  @override
  _ExaminationImageListState createState() => _ExaminationImageListState();
}

class _ExaminationImageListState extends State<ExaminationImageList> {
  List<ExaminationImage> images = []; //Lista zdjęć
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _refreshImages(); //Pobieranie listy zdjęć z bazy danych
  }

  //Metoda pobierania zdjęcia z bazy danych
  void _refreshImages() async {
    images = await dbHelper.getExaminationImages(widget.examination.examinationID!);
    setState(() {});
  }
  //Metoda usuwania zdjęcia z bazy danych
  void _deleteImage(int id) async {
    await dbHelper.deleteExaminationImage(id);
    _refreshImages();
  }
//Przejście do formularza dodawania zdjęcia
  void _navigateToImageForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExaminationImageForm(examination: widget.examination),
      ),
    );
    _refreshImages();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Examination Images'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final img = images[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8.0),
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
                  style: TextStyle(
                    fontSize: 18,
                    //fontWeight: FontWeight.bold,
                    //color: img.result == true ? Colors.red : Colors.green,
                  ),),
                trailing: IconButton(
                  //Przycisk usuwania zdjęcia
                  icon: Icon(Icons.delete, color: Colors.red),
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
        label: Text('Take a photo'),
        icon: Icon(Icons.add_a_photo),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}