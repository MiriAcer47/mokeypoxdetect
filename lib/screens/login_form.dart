import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/user.dart';
import '../services/session_manager.dart';
import 'patient_list.dart';
import 'package:bcrypt/bcrypt.dart';

///Klasa przedstawia formularz logowania, umożliwiający użytkownikowu zalogowanie do aplikacji poprzez podanie nazwy użytkownika oraz PINu.
///Po poprawnym wprowadzeniu danych następuje przekierowanie do ekranu z listą pacjentów.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}


///Stan aplikacji dla ekranu logowania. Zarządza kontrolerami tekstu, logiką walidacji i funkcją logowania.
class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>(); //klucz do zarząrzania walidacją.
  final _usernameController = TextEditingController(); //kontoler pola nazwy użytkownika.
  final _pinController = TextEditingController(); //kontoler pola PIN.
  final dbHelper = DatabaseHelper.instance; //instancja klasy DatabaseHelper

  ///Metoda logowania użytkownika.
  ///Sprawdza czy użytkownik istnieje oraz czy podany PIN jest poprawny,
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text
          .trim(); //Pobiera i czyści nazwę użtkownika.
      String pin = _pinController.text.trim(); //Pobiera i czyści PIN.

      try {
        User? user = await dbHelper.getUser(
            username); //Pobiera użytkownika z bazy.

        if (!mounted) return;

        if (user != null) {
          if (user.isBlocked) {
            print('This account has been blocked');
            // Jeśli użytkownik jest zablokowany, wyświetlamy komunikat i przerywamy logowanie.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This account has been blocked. Please contact the administrator.')),
            );
            return; // Zatrzymujemy logowanie
          }
          bool isPinValid = BCrypt.checkpw(pin, user.pin);

          //Jeśli dane są poprawne przejście do listy pacjentów.

          if (isPinValid) {
            // Logowanie pomyślne, ustawiamy użytkownika w session managerze
            SessionManager().login(user);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PatientList()),
            );
          } else {
            //W przypadku niepoprawnie wprowadzonych danych wyświetla komunikat o błędzie.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid username or PIN')),
            );
          }
        } else{
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid username or PIN')),
            );
        }
      } catch (e) {
        //Obsługa błędu - przy braku połączenia z bazu wyświetla komunikat  o błędzie.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(
            'Error connecting to the database. Please try again.')),
        );
      }
    }
  }

  ///Usuwa kontrolery przy zamykaniu widgetu.
  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          //Pole tekstowe dla nazwy użytkownika.
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Username',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.person, color: colorScheme.primary),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter your username' : null,
          ),
          const SizedBox(height: 16.0),
          //Pole tekstowe dla PIN.
          TextFormField(
            controller: _pinController,
            decoration: InputDecoration(
              hintText: 'PIN',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(Icons.lock, color: colorScheme.primary),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            validator: (value) =>
            value!.isEmpty ? 'Please enter your PIN' : null,
          ),
          const SizedBox(height: 48),
          //Przycisk logowania
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              backgroundColor: colorScheme.primary,
          ),
            child: Text('Login',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
        ],
      ),
    );
  }
}
