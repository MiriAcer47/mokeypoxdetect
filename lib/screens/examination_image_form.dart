import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/examination.dart';
import '../models/examination_image.dart';
import '../database_helper.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:path/path.dart';
import 'package:path/path.dart' as Path;
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
  bool _isSaving = false;


  @override
  void initState() {
    super.initState();
    _takePhoto(); //Automatyczne uruchoienie kamery po otwarciu ekranu
  }

  //Metoda służąca do uruchamiania aparatu i zapisu zdjęcia
  Future<void> _takePhoto() async {

    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile != null) {
      Directory appDir = await getApplicationDocumentsDirectory(); //Pobranie katalogu aplikacji
      String fileName = Path.basename(pickedFile.path); //Nazwa pliku ze zdjeciem
      String newPath = Path.join(appDir.path, fileName); //Nowa ścieżka do zapisu zdjęcia
      File savedImage = await File(pickedFile.path).copy(newPath); //Kopiowanie zdjęcia do katalogu

      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  //Metoda zapisu zdjęcia do bazy danych
  Future<void> _saveImage() async {
    if (_imageFile != null) {
      setState(() {
        _isSaving = true;
      });
      ExaminationImage image = ExaminationImage(
        examinationID: widget.examination.examinationID!,
        imgPath: _imageFile!.path,
        result: _result,
      );
      try {
        await dbHelper.insertExaminationImage(
            image); //Wstawia zdjęcie do bazy danych
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imaged saved successfully.')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error saving image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image. Please try again')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please take a photo')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: AppBar(title: Text('New Examination Image',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _imageFile == null
          ? Expanded(
          child: Center(
            child: Text('No image captured.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,),
          ),
        ),
    )
        : Expanded(
          child: Column(
          children: [
            Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline, width: 2),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.file(
              _imageFile!,
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover,
              ),
            ),
          ),
                    //Przełącznik wyniku zdjęcia
          SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
              child:
              Text(
                'Result',
              style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              ),
              ),
         ),
         SizedBox(height: 8),
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                isSelected: [_result == true, _result == false],
                onPressed: (int index) {
                  setState(() {
                    _result = index == 0;
                  });
                },
                selectedColor: colorScheme.onPrimary,
                color: colorScheme.primary,
                fillColor: colorScheme.primary.withOpacity(0.2),
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth: MediaQuery.of(context).size.width * 0.4,
                ),
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
              ],
                ),
                ),
              SizedBox(height: 32),
              //Przycisk zapisu zdjęcia
              ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveImage,
                  icon: _isSaving
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary, strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.save, color: colorScheme.onPrimary),
                      label: Text(
                        'Save Image',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
                  ),
              ),
            ],
          ),
        ),
    );
  }
}
