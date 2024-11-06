import 'dart:io';
import 'package:flutter/material.dart';
import 'package:monkey/models/examination_image.dart';
import '../models/patient.dart';
import '../models/examination.dart';
import '../database_helper.dart';
import 'examination_form.dart';
import 'examination_image_list.dart';
import 'package:intl/intl.dart';
import 'alertDialog.dart';
import 'package:share_plus/share_plus.dart';

/// Klasa przedstawiająca ekran z listą badań pacjenta.
///
/// Umożliwia przeglądanie, dodawanie, edytowanie, usuwanie badania.
/// Dodatkowo, pozwala na udostępnianie wyników badań.
class ExaminationList extends StatefulWidget {

  /// Pacjent, którego badania są wyświetlane.
  final Patient patient;

  const ExaminationList({super.key, required this.patient});

  @override
  _ExaminationListState createState() => _ExaminationListState();
}

class _ExaminationListState extends State<ExaminationList> {
  /// Lista wszystkich badań pacjenta.
  List<Examination> examinations = [];

  /// Instancja klasy 'DatabaseHelper' do interakcji z bazą danych.
  final dbHelper = DatabaseHelper.instance;

  /// Formatowanie daty w formacie 'yyyy-MM-dd'
  final dateFormat = DateFormat('yyyy-MM-dd');

  /// Metoda wywołana podczas inicjalizacji stanu.
  @override
  void initState() {
    super.initState();
    _refreshExaminations();
  }

  /// Pobiera badania pacjenta z bazy danych i aktualizuje listę badań.
  void _refreshExaminations() async {
    examinations = await dbHelper.getExaminations(widget.patient.patientID!);
    setState(() {});
  }

  /// Usuwa badanie z bazy danych na podstawie jego ID.
  ///
  /// Parametr:
  /// - [id]: ID badania do usunięcia.
  void _deleteExamination(int id) async {
    await dbHelper.deleteExamination(id);
    _refreshExaminations();
  }

  /// Nawiguje do formularza dodawania lub edycji badania.
  ///
  /// Parametr:
  /// - [exam]: Opcjonalny obiekt 'Examination' do edycji. Jeśli null formularz służy do dodawania nowego badania.
  void _navigateToExaminationForm({Examination? exam}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExaminationForm(
          patient: widget.patient,
          examination: exam,
        ),
      ),
    );
    _refreshExaminations();
  }

  /// Wyświetla okno dialogowe potwierdzające usunięcie badania.
  ///
  /// Parametr:
  /// - [id]: ID badamia do usunięcia.
  void _confirmDeleteExamintation(int id){
    CCupertinoAlertDialog.show(
      context: context,
      title: "Delete examination",
      content: 'Do you really want to delete this examination?',
      onConfirm: (){
        _deleteExamination(id);
      },
    );
  }

  /// Metoda umożliwiająca udostępnianie wyników badania.
  ///
  /// Parametr:
  /// - [exam]: Obiekt 'Examination', którego wyniki mają zostać udostępnione.
  Future<void> _shareExamination(Examination exam) async{
    print('sending results');
    String shareContent = '''
    Patient: ${widget.patient.firstName} ${widget.patient.secondName}
    Examination Date: ${dateFormat.format(exam.date)} 
    Final Result: ${exam.finalResult == true ? 'Positive' : (exam.finalResult == false ? 'Negative' : 'Unknown')}
    
    Notes:
    ${exam.notes ?? 'No notes'}
    
    ''';

   try{
      /*List<ExaminationImage> examImages = await dbHelper.getExaminationImages(exam.examinationID!);

      List<XFile> xFiles = examImages
      .map((img) => XFile(img.imgPath))
      .where((xfile) => xfile.path.isNotEmpty && File(xfile.path).existsSync())
      .toList();

      if(xFiles.isNotEmpty) {
        await Share.shareXFiles(
          xFiles,
          text: shareContent,
          subject: 'Examination details ${widget.patient.firstName} ${widget
              .patient.secondName}',
        );
      }else */ {

        await Share.share(
          shareContent,
          subject: 'Examination details ${widget.patient.firstName} ${widget
          .patient.secondName}',
        );
      }
     print('results sent');
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There was promlen in sharing the examination. Try again.')),
      );
      print('Error sharing examination: $e');
    }
  }

  /// Buduje interfejs użytkownika ekranu z listą badań pacjenta.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient.firstName} ${widget.patient.secondName} Examinations',
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimary,
        ),),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: examinations.isEmpty ? Center(
          child: Text('No examination found.',style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant,
          ),),
        )
        : ListView.builder(
          itemCount: examinations.length,
          itemBuilder: (context, index) {
            final exam = examinations[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
              //side: BorderSide(
                //color: colorScheme.outline,
              //),
              ),
              color: colorScheme.surfaceContainer,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
                onTap: () {
                  _navigateToExaminationForm(exam: exam);

                /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      ExaminationForm(
                        patient: widget.patient,
                        examination: exam,
                      ),
                          //ExaminationImageList(examination: exam),
                    ),
                  );

                 */

                },
                title: Text(
                  dateFormat.format(exam.date),
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Final Result: ${exam.finalResult == true ? 'Positive' : 'Negative'}',
                    style: textTheme.labelLarge?.copyWith(
                      color: exam.finalResult == true
                          ? colorScheme.error
                          : Colors.green.shade400,
                    ),
                  ),
                ),
                trailing: Row(mainAxisSize: MainAxisSize.min,
                    children: [
                  //Przycisk edycji badania
                  IconButton(
                    icon: Icon(Icons.send_outlined, color: colorScheme.surfaceTint),
                    onPressed: () =>  _shareExamination(exam),
                  ),
                  //Przycisk usunięcia badania
                  IconButton(
                    icon: Icon(Icons.delete, color: colorScheme.error),
                    //onPressed: () =>  _deleteExamination(exam.examinationID!),
                    onPressed: () => _confirmDeleteExamintation(exam.examinationID!),
                  ),
                ]),
               /* trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Edit') {
                      _navigateToExaminationForm(exam: exam);
                    } else if (value == 'Delete') {
                      _deleteExamination(exam.examinationID!);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return ['Edit', 'Delete'].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),*/
              ),
            );
          },
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToExaminationForm(),
        label: Text('Add examination',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(Icons.add,  color: colorScheme.onPrimary),
        backgroundColor: colorScheme.secondary,
      ),
    );
  }
}
