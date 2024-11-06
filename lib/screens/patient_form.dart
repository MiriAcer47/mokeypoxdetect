import 'package:flutter/material.dart';
import 'package:monkey/screens/patient_list.dart';
import 'package:monkey/styles.dart';
import '../models/patient.dart';
import '../database_helper.dart';
//import '../styles.dart';
import 'package:intl/intl.dart';


/// Klasa przedstawiająca formularz dodawania lub edycji danych pacjenta.
///
/// Umożliwia użytkownikowi wprowadzenie lub modyfikację informacji o pacjencie, takich jak imię, nazwisko,
/// płeć, data urodzenia, numer telefonu, email oraz PESEL.
/// Po zapisaniu danych, użytkownik jest przekierowany z powrotem do listy pacjentów.
class PatientForm extends StatefulWidget {
  ///Obiekt 'Patient' do edycji. Jeśli jest 'null', formularz służy do dodawania nowego pacjenta.
  final Patient? patient;

  ///Konstruktor klasy 'PatientFrom'.
  ///
  /// Parametr:
  /// - [patient]: Opcjonalny obiekt 'Patient' do edycji.
  const PatientForm({super.key, this.patient});

  @override
  _PatientFormState createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  /// Klucz formularza do zarządzania walidacją.
  final _formKey = GlobalKey<FormState>();

  /// Instancja klasy 'DatabaseHelper' do interakcji z bazą danych.
  final dbHelper = DatabaseHelper.instance;

  /// Imię pacjenta.
  late String _firstName;

  /// Nazwisko pacjenta.
  late String _secondName;

  /// Płeć pacjenta ('M'  dla mężczyzny, 'F' dla kobiety)
  late String _gender;

  /// Data urodzenia pacjenta.
  late DateTime _birthDate;

  /// Numer telefonu pacjenta.
  String? _telNo;

  /// Email pacjenta.
  String? _email;

  /// Numer PESEL pacjenta.
  String? _pesel;


  /// Metoda wywoływana podczas inicjalizacji stanu.
  ///
  /// Jeśli edytujemy istniejącego pacjenta, wczytuje jego dane do formularza.
  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      //Jeśli edycja danych istniejącego pacjenta - wczytanie jego danych
      _firstName = widget.patient!.firstName;
      _secondName = widget.patient!.secondName;
      _gender = widget.patient!.gender;
      _birthDate = widget.patient!.birthDate;
      _telNo = widget.patient!.telNo;
      _email = widget.patient!.email;
      _pesel = widget.patient!.pesel;
    } else {
      //Jeśli dodajemy nowego pacjenta - ustawienie domyślnych wartości
      _firstName = '';
      _secondName = '';
      _gender = 'M';
      _birthDate = DateTime.now();
      _telNo = '';
      _email = '';
      _pesel = '';
    }
  }

  /// Metoda zapisująca dane pacjenta do bazy.
  ///
  /// Jeśli pacjent jest nowy, dodaje go do bazy. W przeciwnym razie, aktualizuje istniejący rekord.
  /// Po zapisaniu, przekierowuje użytkownika z powrotem do listy pacjentów.
  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final patient = Patient(
        patientID: widget.patient?.patientID,
        firstName: _firstName,
        secondName: _secondName,
        gender: _gender,
        birthDate: _birthDate,
        telNo: _telNo,
        email: _email,
        pesel: _pesel,
      );
      try {
        if (widget.patient == null) {
          //Dodawanie nowego pacjenta
          await dbHelper.insertPatient(patient);
          print("New patient added successfully.");
        } else {
          //Aktualizacja istniejącego pacjenta
          await dbHelper.updatePatient(patient);
          print("Patient updated successfully.");}
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientList()),
        );
      } catch(e) {
    // Obsługa błędu podczas zapisywania.
    print('Error saving patient: $e');
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Error saving patient. Please try again.')),
    );
    }
  }

  else {
  print('Form validation failed');
  }
}

  ///Metoda wywoływana podczas wyboru daty urodzenia w kalendarzu.
  ///
  /// Parametr:
  /// - [context]: Kontekst aplikacji.
  ///
  /// Aktualizuje datę urodzenia pacjenta, jeśli użytkownik wybierze nową datę.
  Future<void> _selectBirthDate(BuildContext context) async {

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900), //minimalna data
      lastDate: DateTime.now(), //maksymalna data
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked; //aktualizacja daty urodzenia
      });
    }
  }

  /// Buduje interfejs użytkownika formularza pacjenta.
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;


    return Scaffold(
      //resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.patient == null ? 'Add patient' : 'Edit patient data',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary),
          ),
            backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          //Formularz wprowadzania danych pacjenta
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                //Pole tekstowe imienia pacjenta
                TextFormField(
                  initialValue: _firstName,
                  decoration: InputDecoration(
                      labelText: 'First Name',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.person, color: colorScheme.primary),
                    ),
                    //filled: true,
                    //fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter first name' : null,
                  onSaved: (value) => _firstName = value!,
                ),
                  const SizedBox(height: 20),
                //Pole tekstowe nazwiska pacjenta
                TextFormField(
                  initialValue: _secondName,
                  decoration: InputDecoration(labelText: 'Surname',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.person_outline, color: colorScheme.primary),
                    ),
                    //filled: true,
                    //fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter surname' : null,
                  onSaved: (value) => _secondName = value!,
                ),
                  const SizedBox(height: 20),
                //Pole wyboru płci - M - mężczyzna, F - kobieta
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(labelText: 'Gender',
                    prefixIcon:
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.people, color: colorScheme.primary),
                    ),
                    //filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['M', 'F'].map((label) {
                    return DropdownMenuItem(
                      value: label,
                      child: Text(label == 'M' ? 'Male' : 'Female'),);
                        //style: TextStyle(fontSize: 16),),);

                    /*items: ['M', 'F']
                      .map((label) => DropdownMenuItem(
                    child: Text(label),
                    value: label,
                  )).toList(),*/

                  }).toList(),
                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                  //iconSize: 30,
                  //isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                  onSaved: (value) => _gender = value!,
                ),
                  const SizedBox(height: 16),
                //Pole wyboru daty urodzenia
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Birth date',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.calendar_today, color: colorScheme.primary),
                      ),
                      //filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(
                      text: dateFormat.format(_birthDate),
                    ),
                    onTap: () => _selectBirthDate(context),
                  ),
                  const SizedBox(height: 20),

                //Pole tekstowe numetu telefonu
                TextFormField(
                  initialValue: _telNo,
                  decoration: InputDecoration(labelText: 'Telephone Number',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.phone, color: colorScheme.primary),
                  ),
                    //filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSaved: (value) => _telNo = value,
                ),
                  const SizedBox(height: 16),

                //Pole tekstowe adresu e-mail
                TextFormField(
                  initialValue: _email,
                  decoration: InputDecoration(labelText: 'Email', prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.email, color: colorScheme.primary),
                  ),
                    //filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSaved: (value) => _email = value,
                ),
                  const SizedBox(height: 20),

                //Pole tekstowe numeru pesel
                TextFormField(
                  initialValue: _pesel,
                  decoration: InputDecoration(labelText: 'PESEL',  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.assignment_ind, color: colorScheme.primary),
                  ),
                    //filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSaved: (value) => _pesel = value,
                ),
                  const SizedBox(height: 48),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: _savePatient,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor: colorScheme.primary,
                      ),
                      child: Text('Save',
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ),
        ),

    );
  }
}

