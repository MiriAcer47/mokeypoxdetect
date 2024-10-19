import 'package:flutter/material.dart';
import 'package:monkey/screens/patient_list.dart';
import 'package:monkey/styles.dart';
import '../models/patient.dart';
import '../database_helper.dart';
//import '../styles.dart';
import 'package:intl/intl.dart';


//Klasa przedstawiająca formularz dodawania lub edycji danych pacjenta
class PatientForm extends StatefulWidget {
  final Patient? patient;

  const PatientForm({this.patient});

  @override
  _PatientFormState createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;

  late String _firstName;
  late String _secondName;
  late String _gender;
  late DateTime _birthDate;
  String? _telNo;
  String? _email;
  String? _pesel;

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

//Metoda zapisu danych pacjenta
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
    // Handle any errors with saving
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

  //Metoda pozwalająca na wybór daty urodzenia w kalendarzu
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

