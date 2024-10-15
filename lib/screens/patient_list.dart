import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/patient.dart';
import 'patient_form.dart';
import 'examination_list.dart';
import 'alertDialog.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

//Klasa przedstawiająca ekran z listą pacjentów z metodami wyszukiwania pacjenta z listy, dodawania, edyci danych i usuwania pacjentów
class PatientList extends StatefulWidget {
  @override
  _PatientListState createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  List<Patient> patients = []; //Lista pacjentów
  List<Patient> filteredPatients = []; //Filtrowana lista pacjentów
  final dbHelper = DatabaseHelper.instance;
  final dateFormat = DateFormat('yyyy-MM-dd');

  TextEditingController _searchController = TextEditingController(); //kontroler pola wyszukiwania
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _refreshPatients(); //obranie listy pacjentów z bazy
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  //Metoda wywoływana przy zmianie tekstu w polu wyszukiwania
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _filterPatients(); //filtracja pacjentów
    });
  }

  //Pobranie pacjentów z bazy danych i ich filtracja
  void _refreshPatients() async {
    patients = await dbHelper.getPatients();
    _filterPatients();
  }

  //Filtracja pacjentów po imieniu, nazwisku, numerze pesel
  void _filterPatients() {
    if (_searchQuery.isEmpty) {
      filteredPatients = patients;
    } else {
      filteredPatients = patients.where((patient) {
        return patient.firstName.toLowerCase().contains(_searchQuery) ||
            patient.secondName.toLowerCase().contains(_searchQuery) ||
            (patient.pesel != null && patient.pesel!.toLowerCase().contains(_searchQuery));
      }).toList();
    }
    setState(() {});
  }

  //Usunięcie pacjentów z bazy
  void _deletePatient(int id) async {
    await dbHelper.deletePatient(id);
    _refreshPatients();
  }

  //Przejście do formularza dodawania/edytowania pacjentów
  void _navigateToPatientForm({Patient? patient}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientForm(patient: patient),
      ),
    );
    _refreshPatients();
  }

  void _confirmDeletePatient(int id){
    CCupertinoAlertDialog.show(
      context: context,
      title: "Delete Patient",
      content: 'Do you really want to delete this patient?',
      onConfirm: (){
        _deletePatient(id);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              //wylogowanie użytkownika, powrót do ekranu logowania
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                labelText: 'Search by PESEL, First Name, or Second Name',
                prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

    ),
          SizedBox(height: 16.0),
          //lista pacjentów
           ListView.builder(
              shrinkWrap: true,
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                child:  ListTile(
                  title: Text('${patient.firstName} ${patient.secondName}'),
                  subtitle: Text(
                      'Gender: ${patient.gender}, Birth Date: ${dateFormat.format(patient.birthDate)}'),
                  onTap: () {
                    //Nawigacja do ekranu badań pacjenta
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExaminationList(patient: patient),
                      ),
                    );
                  },
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                   //Przycisk edycji pacjenta
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToPatientForm(patient: patient),
                    ),
                    //Przycisk usunięcia pacjenta
                    IconButton(
                      icon: Icon(Icons.delete, color:Colors.red),
                      onPressed: () => _confirmDeletePatient(patient.patientID!),
                      //onPressed: () => _deletePatient(patient.patientID!),
                    ),
                  ]),
                  ),
                );
              },
            ),
          ],
          ),
      ),
    ),
      //Przycisk dodawania nowego pacjenta
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToPatientForm(),
        label: Text('Add patient'),
        icon: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
