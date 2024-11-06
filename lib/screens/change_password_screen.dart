import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart'; // Upewnij się, że dodałeś bcrypt do pubspec.yaml
import 'package:monkey/screens/patient_list.dart';
import '../database_helper.dart';
import '../models/user.dart';
import '../services/session_manager.dart';

/// Klasa przedstawiająca ekran zmiany PIN użytkownika.
///
/// Umożliwia użytkownikowi aktualizację swojego PIN poprzez wprowadzenie aktualnego oraz nowego PINu.
/// Po aktualizacji PINu użytkownik jest przekierowany na ekran listy pacjentów.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  /// Klucz formularza do zarządzania walidacją.
  final _formKey = GlobalKey<FormState>();

  /// Kontroler pola obecnego PINu.
  final TextEditingController _oldPinController = TextEditingController();

  /// Kontroler pola nowego PINu.
  final TextEditingController _newPinController = TextEditingController();

  /// Kontroler pola potwierdzenia nowego PINu.
  final TextEditingController _confirmNewPinController = TextEditingController();

  /// Instancja klasy `DatabaseHelper` do interakcji z bazą danych.
  final dbHelper = DatabaseHelper.instance;

  /// Metoda zmiany PINu użytkownika.
  ///
  /// Sprawdza poprawność obecnego PINu oraz zgodność nowego PINu.
  /// Po udanej zmianie PINu, aktualizuje dane użytkownika w bazie.
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      String oldPin = _oldPinController.text.trim();
      String newPin = _newPinController.text.trim();
      String confirmNewPin = _confirmNewPinController.text.trim();

      if (newPin != confirmNewPin) {
        // Jeśli nowy PIN i potwierdzony PIN są różne
        print('New PINs do not match');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New PINs do not match')),
        );
        return;
      }

      try {
        // Uzyskaj aktualnie zalogowanego użytkownika
        User? currentUser = SessionManager().getLoggedInUser();
        if (currentUser != null) {
          // Sprawdzenie, czy stary PIN jest poprawny
          bool isOldPinCorrect = BCrypt.checkpw(oldPin, currentUser.pin);

          if (isOldPinCorrect) {
            // Haszowanie nowego PINu
            String hashedNewPin = BCrypt.hashpw(newPin, BCrypt.gensalt());

            // Aktualizacja PINu w bazie
            currentUser.pin = hashedNewPin;
            await dbHelper.updateUser(currentUser);
            print('Password changed successfully!');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully!')),
            );

            // Nawigacja z powrotem do listy pacjentów
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PatientList()), // Powrót na ekran listy pacjentów
                  (Route<dynamic> route) => false,
            );

          } else {
            // Stary PIN nie jest poprawny
            print('Incorrect old PIN');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incorrect old PIN')),
            );
          }
        } else {
          // Użytkownik nie istnieje
          print('User not found');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      } catch (e) {
        print('Error changing password: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error changing password. Please try again.')),
        );
      }
    }
  }

  ///Buduje interfejs użytkownika ekranu zmiany PINu.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon:Icon(Icons.arrow_back, color: colorScheme.onPrimary,),
    onPressed: (){
      //Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PatientList()), // Powrót na ekran listy pacjentów
      (Route<dynamic> route) => false,);
    },tooltip: 'Go back',),
        title: Text(
          'Change PIN',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),),
        backgroundColor: colorScheme.primary,
      ),
        body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
    child: Column(
    children: [
    const SizedBox(height: 60),
    Text(
    'Update your PIN',
    style: textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.bold,
    //color: colorScheme.onSurface,
    color: colorScheme.primary,
    ),
    textAlign: TextAlign.center,
    ),
    const SizedBox(height:20.0),
    Text(
    'Enter your current PIN and choose a new PIN to update it.',
    style: textTheme.bodyMedium?.copyWith(
    fontWeight: FontWeight.bold,
    //color: colorScheme.onSurface,
    color: colorScheme.primary,
    ),
    textAlign: TextAlign.center,
    ),
    const SizedBox(height: 40,),
    Form(
          key: _formKey,
          child: Column(
            children: [

              /// Pole tekstowe obecnego PINu.
              TextFormField(
                controller: _oldPinController,
                decoration: InputDecoration(
                  labelText: 'Current PIN',
                  prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Icon(Icons.lock, color: colorScheme.primary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current PIN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ///Pole tekstowe nowego PINu.
              TextFormField(
                controller: _newPinController,
                decoration: InputDecoration(
                  labelText: 'New PIN',
                  prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.lock_outline, color: colorScheme.primary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new PIN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              /// Pole tekstowe potwierdzenia nowego PINu.
              TextFormField(
                controller: _confirmNewPinController,
                decoration: InputDecoration(
                  labelText: 'Confirm New PIN',
                  prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.lock_outline, color: colorScheme.primary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new PIN';
                  }
                  if (value != _newPinController.text) {
                    return 'New PINs do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),

                /// Przycisk zapisu zmiany PINu.
                SizedBox(
                 width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                   onPressed: _changePassword,
                   style:ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(25),
                     ),
                  backgroundColor: colorScheme.primary,
                  ),
                child: Text(
                  'Save',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,),
                   ),
                  ),
                ),
            ],
          ),
        ),
        ],
      ),
      ),
        ),
    );
  }
}
