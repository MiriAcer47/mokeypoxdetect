import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/examination.dart';
import '../models/examination_image.dart';
import '../database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import '../styles.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:image/image.dart' as img; // For image processing

/// Klasa przedstawiająca ekran dodawania nowego zdjęcia w ramach danego badania.
///
/// Umożliwia użytkownikowi zrobienie zdjęcia za pomocą kamery urządzenia lub wybór zdjęcia z galerii.
/// Następnie zdjęcie jest automatycznie klasyfikowane przy użyciu modelu TensorFlow Lite.
class ExaminationImageFormTL extends StatefulWidget {
  /// Obiekt badania, do którego dodawane jest zdjęcie.
  final Examination examination;

  /// Typ zdjęcia:
  /// 1: zrobienie zdjęcia kamerą urządzenia
  /// 2: wybór zdjęcia z galerii.
  final int typ;

  /// Konstruktor klasy 'ExaminationImageFormTL'
  ///
  /// Parametry:
  /// - [examination]: Obiekt badania, dla którego klasyfikowane jest zdjęcie.
  /// - [typ]: Typ zdjęcia
  const ExaminationImageFormTL({super.key, required this.examination, required this.typ});

  @override
  _ExaminationImageFormState createState() => _ExaminationImageFormState();
}

class _ExaminationImageFormState extends State<ExaminationImageFormTL> {
  /// Plik zdjęcia wybranego lub zrobionego przez użytkownika.
  File? _imageFile;

  /// Obiekt do obsługi wyboru zdjęcia.
  final picker = ImagePicker();

  /// Instancja klasy 'DatabaseHelper' do interakcji z bazą danych.
  final dbHelper = DatabaseHelper.instance;

  /// Wynik klasyfikacji zdjęcia (true - pozytywny, false - negatywny)
  bool? _result = false;

  /// Flaga informująca o trakcie zapisywania zdjęcia.
  bool _isSaving = false;

  /// Flaga informująca o trakcie klasyfikacji obrazu.
  bool _isClassifying = false;

  /// Etykieta klasyfikacji
  String? _classificationLabel;

  /// Poziom dokładości klasyfikacji.
  double? _classificationConfidence;

  /// Interpreter TensorFlow Lite do klasyfikacji obrazów.
  late Interpreter _interpreter;

  /// Lista etykiet używanych przez model.
  List<String>? _labels;

  /// Rozmiar wejściowy modelu
  int _inputSize = 224;

  /// Średnia wartość pikseli dla normalizacji obrazu.
  final double _imageMean = 0;

  /// Wartość standardowa dla normalizacji obrazu.
  final double _imageStd = 1;

  /// Liczba kanałów kolorów w obrazie.
  int _numChannels = 3;

  /// Metoda wywoływana podczas inicjalizacji stanu.
  ///
  /// Ładuje model TensorFlow Lite oraz automatycznie uruchamia kamerę urządzenia lub wybór zdjęcia z galerii.
  @override
  void initState() {
    super.initState();
    _loadModel();
    if (widget.typ == 1) {
      _takePhoto();
    } else {
      _pickImageFromGallery();
    }
  }

  /// Metoda służąca do ładowania modelu TensorFlow Lite oraz etykiet z plików z zasobów.
  Future<void> _loadModel() async {
    try {
      // Ładuje model
      _interpreter = await Interpreter.fromAsset('assets/model_mobilenet.tflite');
      print("Model loaded successfully");

      // Ładuje etykiety
      String labelsData = await rootBundle.loadString('assets/label.txt');
      _labels = labelsData.split('\n');
      print('Labels loaded: ${_labels?.length}');

      // Bierze rozmiar wejściowy modelu [1, height, width, channels]
      var inputShape = _interpreter.getInputTensor(0).shape;
      _inputSize = inputShape[1];
      _numChannels = inputShape[3];
      print('Model input size: $_inputSize x $_inputSize x $_numChannels');
    } catch (e) {
      print("Error loading model: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading model. Please try again later.')),
      );
    }
  }

  /// Wybiera obraz z galerii urządzenia.
  ///
  /// Po wybraniu zdjęcia, klasyfikuje je przy użyciu modelu.
  Future<void> _pickImageFromGallery() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    try {
      if (pickedImage != null) {
        setState(() {
          _imageFile = File(pickedImage.path);
        });
        _classifyImage(_imageFile!);
      }
    } catch (e) {
      print("Error during image classification: $e");
    }
  }

  /// Metoda służąca do uruchamiania aparatu i zrobienia zdjęcia.
  ///
  /// Po zrobieniu zdjęcia, zapisuje je w katalogu aplikacji oraz klasyfikuje.
  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile != null) {
      Directory appDir = await getApplicationDocumentsDirectory(); // Pobranie katalogu aplikacji
      String fileName = Path.basename(pickedFile.path); // Nazwa pliku ze zdjęciem
      String newPath = Path.join(appDir.path, fileName); // Nowa ścieżka do zapisu zdjęcia
      File savedImage = await File(pickedFile.path).copy(newPath); // Kopiowanie zdjęcia do katalogu

      setState(() {
        _imageFile = savedImage;
      });

      _classifyImage(savedImage);
    }
  }

  /// Metoda zapisująca zdjęcie do bazy danych.
  ///
  /// Jeśli zdjęcie zostało wybrane z galerii lub zrobione, zapisuje je wraz z wynikiem klasyfikacji.
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
        await dbHelper.insertExaminationImage(image); // Wstawia zdjęcie do bazy danych
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved successfully.')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error saving image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving image. Please try again.')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a photo')),
      );
    }
  }

  /// Przetwarza i klasyfikuje obraz przy użyciu modelu TensorFlow Lite.
  ///
  /// Parametr:
  /// - [image]: Obiekt 'File' reprezentujący obraz do klasyfikacji.
  ///
  /// Aktualizuje wynik klasyfikacji i wyświetla komunikat z wynikiem.
  Future<void> _classifyImage(File image) async {
    setState(() {
      _isClassifying = true;
    });
    try {
      print("Processing image");

      // Ładowanie i przetwarzanie zdjęcia
      img.Image? imageInput = img.decodeImage(image.readAsBytesSync());

      if (imageInput == null) {
        print("Failed to decode image.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to decode image. Please try another photo.')),
        );
        return;
      }

      // Zmiana rozmiaru zdjęcia
      img.Image resizedImage = img.copyResize(imageInput, width: _inputSize, height: _inputSize);

      // Konwersja zdjęcia do 4D
      List<List<List<List<double>>>> input = _imageTo4DList(resizedImage, _inputSize, _imageMean, _imageStd);

      // Dodaje potwierdzenie, aby zweryfikować rozmiar danych wejściowych.
      assert(input.length == 1);
      assert(input[0].length == _inputSize);
      assert(input[0][0].length == _inputSize);
      assert(input[0][0][0].length == _numChannels);

      // Przygotowuje bufor wyjściowy - kształt tensora wyjściowego [1, num_labels]
      List<List<double>> outputBuffer = List.generate(1, (_) => List.filled(_labels!.length, 0.0));

      // Interpreter wykonuje klasyfikację obrazu
      _interpreter.run(input, outputBuffer);

      // Przetwarza dane wyjściowe
      double confidence = outputBuffer[0][0]; // Jedna wartość

      setState(() {
        _classificationConfidence = 1 - confidence;
        _classificationLabel = confidence < 0.5 ? 'Positive' : 'Negative';
        _result = confidence < 0.5;
      });

      print("Classification result: $_classificationLabel ($_classificationConfidence)");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Classification Result: $_classificationLabel (${(_classificationConfidence! * 100).toStringAsFixed(0)}%)',
          ),
        ),
      );
    } catch (e) {
      print("Error during image classification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during image classification. Please try again.')),
      );
    } finally {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  /// Konwertuje obraz do formatu wymaganego przez model
  ///
  /// Parametry:
  /// - [image]: Obiekt 'img.Image' przedstawiający przetworzony obraz.
  /// - [inputSize]: Rozmiar wejściowy modelu.
  /// - [mean]: Średnia wartość pikseli do normalizacji.
  /// - [std]: Wartość standardowa do normalizacji.
  ///
  /// Zwraca:
  /// - 4D lista liczb zmiennoprzecinkowych reprezentująca przetworzony obraz.
  List<List<List<List<double>>>> _imageTo4DList(img.Image image, int inputSize, double mean, double std) {
    List<List<List<List<double>>>> input = List.generate(
      1,
          (_) => List.generate(
        inputSize,
            (y) => List.generate(
          inputSize,
              (x) => List.generate(
            _numChannels,
                (c) {
              int pixel = image.getPixel(x, y);
              switch (c) {
                case 0:
                  return (img.getRed(pixel) - mean) / std;
                case 1:
                  return (img.getGreen(pixel) - mean) / std;
                case 2:
                  return (img.getBlue(pixel) - mean) / std;
                default:
                  return 0.0;
              }
            },
          ),
        ),
      ),
    );
    return input;
  }

  /// Metoda wywoływana przy zamykaniu widgetu.
  ///
  /// Zamyka interpreter TensorFlow Lite.
  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  /// Buduje interfejs użytkownika formularza dodawania zdjęcia.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Result',
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
                child: Text(
                  'No image captured.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
                : Expanded(
              child: Column(
                children: [
                  /// Wyświetlanie wybranego lub zrobionego zdjęcia.
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
                  const SizedBox(height: 32),
                  /// Etykieta sekcji wyboru wyniku klasyfikacji
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Result',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  /// Przełącznik ręcznego wyboru wyniku klasyfikacji.
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(10),
                    isSelected: [_result == true, _result == false],
                    onPressed: (int index) {
                      setState(() {
                        _result = index == 0;
                        // Opcjonalnie, zresetuj klasyfikację, jeśli użytkownik zmienia przełącznik
                        // _classificationLabel = null;
                        // _classificationConfidence = null;
                      });
                    },
                    selectedColor: colorScheme.onPrimary,
                    color: colorScheme.primary,
                    fillColor: _result == true
                        ? colorScheme.error.withOpacity(0.7)
                        : Colors.green.shade400.withOpacity(0.7), // Zwiększona przejrzystość
                    borderColor: colorScheme.primary, // Dodanie koloru obramowania
                    selectedBorderColor: colorScheme.primary, // Kolor obramowania, gdy wybrane
                    constraints: BoxConstraints(
                      minHeight: 40.0,
                      minWidth: MediaQuery.of(context).size.width * 0.4,
                    ),
                    children: const [
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
                  const SizedBox(height: 32),
                  /// Wyświetlanie wyniku klasyfikacji lub wskaźnika ładowania.
                  _isClassifying
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  )
                      : Text(
                    'Classification Result: ${(_classificationConfidence! * 100).toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _classificationLabel == 'Positive'
                          ? colorScheme.error
                          : Colors.green.shade400,
                    ),
                  ),
                ],
              ),
            ),

            // Przycisk zapisu zdjęcia
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// Przycisk Cancel
              ElevatedButton.icon(
                onPressed: _isSaving || _isClassifying
                    ? null
                    : () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.cancel, color: colorScheme.onPrimary),
                label: Text(
                  'Cancel',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: colorScheme.secondary, // Different color for Cancel
                ),
              ),
              /// Przycisk Save Image.
              ElevatedButton.icon(
                onPressed: _isSaving || _isClassifying ? null : _saveImage,
                icon: _isSaving
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
                    : Icon(Icons.save, color: colorScheme.onPrimary),
                label: Text(
                  'Save Image',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
