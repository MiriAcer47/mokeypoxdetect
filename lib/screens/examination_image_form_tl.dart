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

// Klasa przedstawiająca ekran dodawania nowego zdjęcia w ramach danego badania.
// Użytkownik może zrobić zdjęcie kamerą urządzenia i zapisać w bazie
class ExaminationImageFormTL extends StatefulWidget {
  final Examination examination; // Obiekt badania, do którego dodawane jest zdjęcie
  final int typ; // 1: take photo, 2: select from gallery
  ExaminationImageFormTL({required this.examination, required this.typ});

  @override
  _ExaminationImageFormState createState() => _ExaminationImageFormState();
}

class _ExaminationImageFormState extends State<ExaminationImageFormTL> {
  File? _imageFile;
  final picker = ImagePicker(); // Obiekt do obsługi kamery
  final dbHelper = DatabaseHelper.instance;
  bool? _result = false;
  bool _isSaving = false;
//zmienne przechowujące wyniki klasyfikacji
  String? _classificationLabel; // Przechowuje etykietę klasyfikacji (np. "Positive" lub "Negative")
  double? _classificationConfidence; // Przechowuje poziom zaufania klasyfikacji (np. 85%)


  // TensorFlow Lite Interpreter and related variables
  late Interpreter _interpreter;
  List<String>? _labels;
  int _inputSize = 224; // Default input size
  double _imageMean = 0;
  double _imageStd = 1;
  int _numChannels = 3;


  @override
  void initState() {
    super.initState();
    _loadModel();
    if (widget.typ == 1) {
      _takePhoto();
    }
    else {
      _pickImageFromGallery(); // Automatyczne uruchoienie kamery po otwarciu ekranu
    }


  }

  /// Load the TensorFlow Lite model and labels
  Future<void> _loadModel() async {
    try {
      // Load the TFLite model
      _interpreter = await Interpreter.fromAsset('assets/model1mobilenetv2test.tflite');
      print("Model loaded successfully");

      // Load labels
      String labelsData = await rootBundle.loadString('assets/label.txt');
      _labels = labelsData.split('\n');
      print('Labels loaded: ${_labels?.length}');

      // Get input size from the model
      var inputShape = _interpreter.getInputTensor(0).shape;
      // Assuming input shape is [1, height, width, channels]
      _inputSize = inputShape[1];
      _numChannels = inputShape[3];
      print('Model input size: $_inputSize x $_inputSize x $_numChannels');
    } catch (e) {
      print("Error loading model: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading model. Please try again later.')),
      );
    }
  }

  /// Pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
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

  // Metoda służąca do uruchamiania aparatu i zapisu zdjęcia
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

      // Run classification on the captured image
      _classifyImage(savedImage);
    }
  }

  // Metoda zapisu zdjęcia do bazy danych
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
          SnackBar(content: Text('Image saved successfully.')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error saving image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image. Please try again.')),
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

  /// Preprocess the image and classify it using TensorFlow Lite
  Future<void> _classifyImage(File image) async {
    try {
      print("Processing image");

      // Load and preprocess the image
      img.Image? imageInput = img.decodeImage(image.readAsBytesSync());

      if (imageInput == null) {
        print("Failed to decode image.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decode image. Please try another photo.')),
        );
        return;
      }

      // Resize the image
      img.Image resizedImage = img.copyResize(imageInput, width: _inputSize, height: _inputSize);

      // Convert the image to a 4D list [1, height, width, channels]
      List<List<List<List<double>>>> input = _imageTo4DList(resizedImage, _inputSize, _imageMean, _imageStd);

      // Optional: Add assertions to verify input shape
      assert(input.length == 1);
      assert(input[0].length == _inputSize);
      assert(input[0][0].length == _inputSize);
      assert(input[0][0][0].length == _numChannels);

      // Prepare output buffer
      // Assuming the output tensor shape is [1, num_labels]
      List<List<double>> outputBuffer = List.generate(1, (_) => List.filled(_labels!.length, 0.0));

      // Run inference
      _interpreter.run(input, outputBuffer);


      // Process the output
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
        SnackBar(content: Text('Error during image classification. Please try again.')),
      );
    }
  }

  /// Convert image to 4D List as required by the model
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

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Examination Image',
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
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
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
                        // Opcjonalnie, zresetuj klasyfikację, jeśli użytkownik zmienia przełącznik
                       // _classificationLabel = null;
                        //_classificationConfidence = null;
                      });
                    },
                    selectedColor: colorScheme.onPrimary,
                    color: colorScheme.primary,
                    fillColor: _result == true ? colorScheme.error.withOpacity(0.7) : Colors.green.shade400.withOpacity(0.7), // Zwiększona przejrzystość
                    borderColor: colorScheme.primary, // Dodanie koloru obramowania
                    selectedBorderColor: colorScheme.primary, // Kolor obramowania, gdy wybrane
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
                  SizedBox(height: 16),
                  // Wyświetlanie wyniku klasyfikacji
                  Text(
                      'Classification Result: ${(_classificationConfidence! * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _classificationLabel == 'Positive' ? colorScheme.error : Colors.green.shade400,
                      ),
                    ),
                ],
              ),
            ),

            // Przycisk zapisu zdjęcia


          ],
        ),
      ),
      bottomNavigationBar:BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal:16),
          child:Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveImage,
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
                  '  Save Image  ',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
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
