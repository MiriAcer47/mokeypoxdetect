
import 'package:flutter/material.dart';
import 'package:monkey/styles.dart';
import '../models/patient.dart';
import '../models/examination.dart';
import '../models/examination_image.dart';
import 'examination_image_form.dart';
import 'package:image_picker/image_picker.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'alertDialog.dart';

class ExaminationForm extends StatefulWidget {
  final Patient patient;
  final Examination? examination;

  const ExaminationForm({super.key, required this.patient, this.examination});

  @override
  _ExaminationFormState createState() => _ExaminationFormState();
}

class _ExaminationFormState extends State<ExaminationForm> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;

  late DateTime _date;
  bool? _finalResult;
  String? _notes;
  List<ExaminationImage> images = [];

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

  Future<void> _loadImages() async {
    images = await dbHelper.getExaminationImages(widget.examination!.examinationID!);
    setState(() {});
  }

  void _deleteImage(int imageID) async {
    await dbHelper.deleteExaminationImage(imageID);
    _loadImages(); // Odśwież listę zdjęć po usunięciu
  }

  void _saveExamination() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final exam = Examination(
        examinationID: widget.examination?.examinationID,
        patientID: widget.patient.patientID!,
        date: _date,
        finalResult: _finalResult,
        notes: _notes,
      );
      if (widget.examination == null) {
        await dbHelper.insertExamination(exam);
      } else {
        await dbHelper.updateExamination(exam);
      }
      Navigator.pop(context);
    }
  }

  Future<void> _selectExaminationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _confirmDeleteImage(int id) {
    CCupertinoAlertDialog.show(
      context: context,
      title: "Delete Image",
      content: 'Do you really want to delete this image?',
      onConfirm: () {
        _deleteImage(id);
      },
    );
  }

  void _navigateToImageForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExaminationImageForm(examination: widget.examination!),
      ),
    );
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examination == null ? 'Add Examination' : 'Edit Examination',
        style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary),
      ),
      backgroundColor: colorScheme.primary,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
    ),
      body: Padding(
        //padding: const EdgeInsets.all(8),
        padding: const EdgeInsets.only(bottom: 40),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pole wyboru daty
                      // Pole wyboru daty
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(Icons.calendar_today, color: colorScheme.primary),
                          ),
                          // filled: true,
                          // fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        controller: TextEditingController(
                          text: dateFormat.format(_date),
                        ),
                        onTap: () => _selectExaminationDate(context),
                      ),
                      const SizedBox(height: 20),
                      // Przełącznik Wyniku Końcowego
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
                        isSelected: [_finalResult == true, _finalResult == false],
                        onPressed: (int index) {
                          setState(() {
                            _finalResult = index == 0;
                          });
                        },
                        constraints: BoxConstraints(
                          minHeight: 40.0,
                          minWidth: MediaQuery.of(context).size.width*0.4,
                        ),
                        children: const [
                          Text('Pozytywny'),
                          Text('Negatywny'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Pole Notatek
                      TextFormField(
                        initialValue: _notes,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.note, color: colorScheme.primary),
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
                      Text(
                        'Examination Images',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Lista zdjęć
                      images.isEmpty
                          ? Center(child: Text('No images',  style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,),),)
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final img = images[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
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
                                  color: img.result == true ? colorScheme.error : Colors.green[400],
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: colorScheme.error),
                                onPressed: () => _confirmDeleteImage(img.imageID!),
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
            children:[
              Expanded(
                child: ElevatedButton.icon(
                    onPressed: _saveExamination,
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
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                //onPressed: _saveExamination,
                onPressed: _navigateToImageForm,
                icon: Icon(Icons.add_a_photo, color: colorScheme.onPrimary),
                label: Text(
                  'Take Photo',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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