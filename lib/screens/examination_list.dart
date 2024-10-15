import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/examination.dart';
import '../database_helper.dart';
import 'examination_form.dart';
import 'examination_image_list.dart';
import 'package:intl/intl.dart';
import 'alertDialog.dart';

class ExaminationList extends StatefulWidget {
  final Patient patient;

  ExaminationList({required this.patient});

  @override
  _ExaminationListState createState() => _ExaminationListState();
}

class _ExaminationListState extends State<ExaminationList> {
  List<Examination> examinations = [];
  final dbHelper = DatabaseHelper.instance;
  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _refreshExaminations();
  }

  void _refreshExaminations() async {
    examinations = await dbHelper.getExaminations(widget.patient.patientID!);
    setState(() {});
  }

  void _deleteExamination(int id) async {
    await dbHelper.deleteExamination(id);
    _refreshExaminations();
  }

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

  void _confirmDeleteExamintation(int id){
    CCupertinoAlertDialog.show(
      context: context,
      title: "Delete Examination",
      content: 'Do you really want to delete this examination?',
      onConfirm: (){
        _deleteExamination(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient.firstName} ${widget.patient.secondName} Examinations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: examinations.length,
          itemBuilder: (context, index) {
            final exam = examinations[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                onTap: () {
                  Navigator.push(
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

                },
                title: Text(
                  dateFormat.format(exam.date),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Final Result: ${exam.finalResult == true ? 'Positive' : 'Negative'}',
                    style: TextStyle(
                      color: exam.finalResult == true
                          ? Colors.red
                          : Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  //Przycisk edycji badania
                  //IconButton(
                    //icon: Icon(Icons.edit, color: Colors.blue),
                    //onPressed: () =>  _navigateToExaminationForm(exam: exam),
                  //),
                  //Przycisk usunięcia badania
                  IconButton(
                    icon: Icon(Icons.delete, color:Colors.red),
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
        label: Text('Add Examination'),
        icon: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
