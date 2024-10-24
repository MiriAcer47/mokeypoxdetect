import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'user_management_screen.dart';
import '../database_helper.dart';
import '../models/patient.dart';
import '../services/session_manager.dart';
import 'patient_form.dart';
import 'examination_list.dart';
import 'alertDialog.dart';
import 'login_screen.dart';
import 'new_account_screen.dart';
//import 'have_account_check.dart';
import 'change_password_screen.dart';
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
      title: "Delete patient",
      content: 'Do you really want to delete this patient?',
      onConfirm: (){
        _deletePatient(id);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = SessionManager().getLoggedInUser();  // Pobieramy aktualnie zalogowanego użytkownika
    final isAdmin = currentUser?.isAdmin ?? false;  // Sprawdzamy, czy użytkownik jest administratorem
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients list',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
        actions: [
          if (isAdmin)  // Wyświetlamy ikonę tylko jeśli użytkownik jest adminem
            IconButton(
              icon: Icon(Icons.admin_panel_settings),
              onPressed: () {
                // Przejście do ekranu zarządzania użytkownikami
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagementScreen()),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.vpn_key, color: colorScheme.onPrimary),
            onPressed: () {
              //wylogowanie użytkownika, powrót do ekranu logowania
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
          if (isAdmin)  // Wyświetlamy ikonę tylko jeśli użytkownik jest adminem
            IconButton(
              icon: Icon(Icons.person_add, color: colorScheme.onPrimary),
              onPressed: () {
                //wylogowanie użytkownika, powrót do ekranu logowania
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const NewAccountScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.logout, color: colorScheme.onPrimary),
            onPressed: () {
              //wylogowanie użytkownika, powrót do ekranu logowania
              SessionManager().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                hintText: 'Search by PESEL, First Name, or Second Name',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                   borderSide: BorderSide(
                    color: colorScheme.outline,
                    ),
            ),
                  contentPadding: EdgeInsets.all(12),
                ),
                style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface, // Text color for the search
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text('${patient.firstName} ${patient.secondName}',
                  style: textTheme.titleMedium?.copyWith(
                    //fontSize: 18,
                    //fontWeight: FontWeight.bold,
                    color:colorScheme.onSurface,
                  ),

                  ),
                  subtitle: Text(
                      'Gender: ${patient.gender =='M' ? 'Male': 'Female'}, Birth Date: ${dateFormat.format(patient.birthDate)}',
                      style: textTheme.labelMedium?.copyWith(
                      color:colorScheme.onSurfaceVariant,
                //fontSize: 14,
                //),
                      ),
                  ),
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
                      icon: Icon(Icons.edit, color: colorScheme.surfaceTint),
                      onPressed: () => _navigateToPatientForm(patient: patient),
                    ),
                    //Przycisk usunięcia pacjenta
                    IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
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
        label: Text('Add patient',
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
