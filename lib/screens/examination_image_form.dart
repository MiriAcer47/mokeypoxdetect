import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/examination.dart';
import '../models/examination_image.dart';
import '../database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../styles.dart';

//KLasa przedstawiająca ekran dodawania nowego zdjęcia w ramach danego badania.
//Użytkownik może zrobić zdjęcie kamerą urządzenia i zapisać w bazie
class ExaminationImageForm extends StatefulWidget {
  final Examination examination; //Obiekt badania, do którego dodawane jest zdjęcie

  ExaminationImageForm({required this.examination});

  @override
  _ExaminationImageFormState createState() => _ExaminationImageFormState();
}

class _ExaminationImageFormState extends State<ExaminationImageForm> {
  File? _imageFile;
  final picker = ImagePicker(); //Obiekt do obsługi kamery
  final dbHelper = DatabaseHelper.instance;
  bool? _result = false;



  //Metoda służąca do uruchamiania aparatu i zapisu zdjęcia
  Future<void> _takePhoto() async {

    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile != null) {
      Directory appDir = await getApplicationDocumentsDirectory(); //Pobranie katalogu aplikacji
      String fileName = basename(pickedFile.path); //Nazwa pliku ze zdjeciem
      String newPath = join(appDir.path, fileName); //Nowa ścieżka do zapisu zdjęcia
      File savedImage = await File(pickedFile.path).copy(newPath); //Kopiowanie zdjęcia do katalogu

      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  //Metoda zapisu zdjęcia do bazy danych
  void _saveImage() async {
    if (_imageFile != null) {
      ExaminationImage image = ExaminationImage(
        examinationID: widget.examination.examinationID!,
        imgPath: _imageFile!.path,
        result: _result,
      );
      await dbHelper.insertExaminationImage(image); //Wstawia zdjęcie do bazy danych
      Navigator.pop(context as BuildContext);
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Please take a photo')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _takePhoto(); //Automatyczne uruchoienie kamery po otwarciu ekranu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('New Examination Image')),
        body: Center(
          child: _imageFile == null
              ? Text('No image captured.')
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(_imageFile!, height: 350),
                ),
              ),
              //Przełącznik wyniku zdjęcia
              SizedBox(height: 32),
              // Final Result Toggle
              Text(
                'Result',
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),


              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                isSelected: [_result == true, _result == false],
                onPressed: (int index) {
                  setState(() {
                    _result = index == 0;
                  });
                },
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Positive'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Negative'),
                  ),
                ],
              ),
              SizedBox(height: 32),
              //Przycisk zapisu zdjęcia
              ElevatedButton(
                onPressed: _saveImage,
                child: Text('Save Image'),
                style: buttonStyle1,
              ),

            ],
          ),
        ));
  }
}
