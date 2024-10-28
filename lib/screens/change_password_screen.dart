import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart'; // Upewnij się, że dodałeś bcrypt do pubspec.yaml
import 'package:monkey/screens/patient_list.dart';
import '../database_helper.dart';
import '../models/user.dart';
import '../services/session_manager.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmNewPinController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      String oldPin = _oldPinController.text.trim();
      String newPin = _newPinController.text.trim();
      String confirmNewPin = _confirmNewPinController.text.trim();

      if (newPin != confirmNewPin) {
        // Jeśli nowy PIN i potwierdzony PIN są różne
        print('New PINs do not match');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New PINs do not match')),
        );
        return;
      }

      try {
        // Uzyskaj aktualnie zalogowanego użytkownika
        User? currentUser = SessionManager().getLoggedInUser();
        if (currentUser != null) {
          // Sprawdzamy, czy stary PIN jest poprawny
          bool isOldPinCorrect = BCrypt.checkpw(oldPin, currentUser.pin);

          if (isOldPinCorrect) {
            // Haszujemy nowy PIN
            String hashedNewPin = BCrypt.hashpw(newPin, BCrypt.gensalt());

            // Aktualizujemy PIN w bazie
            currentUser.pin = hashedNewPin;
            await dbHelper.updateUser(currentUser);
            print('Password changed successfully!');
            // Wyświetlamy sukces
            ScaffoldMessenger.of(context).showSnackBar(

              SnackBar(content: Text('Password changed successfully!')),
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
              SnackBar(content: Text('Incorrect old PIN')),
            );
          }
        } else {
          // Użytkownik nie istnieje (powinno być to rzadkie)
          print('User not found');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found')),
          );
        }
      } catch (e) {
        // Obsługa błędów (np. problemy z bazą danych)
        print('Error changing password: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing password. Please try again.')),
        );
      }
    }
  }

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
                child: Text('Save',
                style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                ),
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
