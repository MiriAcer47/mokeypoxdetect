import 'package:flutter/material.dart';
import 'package:monkey/styles.dart';
import '../models/user.dart';
import '../database_helper.dart';
import 'login_form.dart';
import 'patient_list.dart';



///Klasa przedstawiająca ekran do rejestracji nowego użytkownika, gdzie użytkownik może założyć nowe konto.
class NewAccountScreen extends StatefulWidget {
  const NewAccountScreen({super.key});

  @override
  _NewAccountScreenState createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {

  /// Klucz formularza do identyfikacji i walidacji formularza.
  final _formKey = GlobalKey<FormState>();

  /// Kontroler pola nazy użytkownika.
  final _usernameController = TextEditingController();

  /// Kontroler pola PIN.
  final _pinController = TextEditingController();

  /// Kontroler pola adresu e-mail.
  final _emailController = TextEditingController();

  /// Instancja klasy 'DatabaseHelper' do interakcji z bazą danych.
  final dbHelper = DatabaseHelper.instance;

  ///Metoda rejestracji nowego użytkownika przy użyciu wprowadznych danych.
  ///
  ///Wyświetle komunikat o powodzeniu lub blędzie.
  Future<void> _signup() async {
    //Walidacja danych formularza
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      String pin = _pinController.text.trim();
      String email = _emailController.text.trim();

      //Utworzenie nowego obiektu użytkownika.
      User newUser = User(
        username: username,
        pin: pin,
        email: email,
      );
      if (!mounted) return;
      try {

        //Wstawia nowego użytkownika do bazy.
        await dbHelper.insertUser(newUser);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PatientList()), // Powrót na ekran listy pacjentów
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        //Obsługa błędu, gdy nazwa użytkownika lub adres e-mail już istnieją
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username or email already exists')),
        );
      }
    }
  }

  /// Usuwa kontrolery przy zamykaniu widgetu.
  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Buduje interfejs użytkownika ekranu rejestracji nowego użytkownika.
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
             // Powrót na ekran listy pacjentów.
             Navigator.pushAndRemoveUntil(
              context,
               MaterialPageRoute(builder: (context) => PatientList()), // Powrót na ekran listy pacjentów
                   (Route<dynamic> route) => false,);
      },
          tooltip: 'Go back',
        ), title: Text('Create an Account',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
              ),
              backgroundColor: colorScheme.primary,
              //iconTheme: IconThemeData(color: colorScheme.onPrimary),
              ),
        body: SingleChildScrollView(
        child: Center(
          child:Padding(
          padding: const EdgeInsets.all(24),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const SizedBox(height: 80),
              Text(
              'Enter User Data to Create an Account',
          style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          //color: colorScheme.onSurface,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
          ),
         const SizedBox(height:48.0),
          Form(
          key: _formKey,
          child: Column(
            children: [
              //Pole tekstowe dla nazwy użytkownika
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                hintText: 'Username',
                prefixIcon: Padding(
                padding: const EdgeInsets.all(16),
                  child: Icon(Icons.person, color: colorScheme.primary),),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter a username' : null,

              ),
              const SizedBox(height: 16.0),
              // Pole tekstowe dla pinu
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: Padding(
                padding: const EdgeInsets.all(16),
                  child: Icon(Icons.email, color: colorScheme.primary),),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                ),
              ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an e-mail' : null,
              ),
              const SizedBox(height: 16.0),
              //Pole tekstowe dla adresu email
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
                validator: (value) => value!.isEmpty ? 'Please enter a PIN' : null,
              ),
              const SizedBox(height: 48.0),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: ElevatedButton(
                onPressed: _signup,
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

            const SizedBox(height: 16.0),
           /* HaveAccountCheck(
            login: false,
            press: (){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => PatientList()), // Powrót na ekran listy pacjentów
                    (Route<dynamic> route) => false,
              );
            },
            ),*/
          ],
          ),
        ),
      ],
        ),
    ),
    ),
      ),
    );
  }
}
