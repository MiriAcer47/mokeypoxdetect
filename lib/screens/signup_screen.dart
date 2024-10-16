import 'package:flutter/material.dart';
import 'package:monkey/screens/login_screen.dart';
import 'package:monkey/styles.dart';
import '../models/user.dart';
import '../database_helper.dart';
import '../styles.dart';
import 'login_form.dart';


//Klasa przedstawiająca ekran do rejestracji nowego użytkownika, gdzie użytkownik może założyć nowe konto.
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(); //Kontroler pola nazwy uzytkownika
  final _pinController = TextEditingController(); //Kontroler pola PIN
  final _emailController = TextEditingController(); //Kontroler pola adresu e-mail
  final dbHelper = DatabaseHelper.instance;

  //Metoda rejestracji nowego użytkownika
  void _signup() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      String pin = _pinController.text.trim();
      String email = _emailController.text.trim();

      User newUser = User(
        username: username,
        pin: pin,
        email: email,
      );

      try {
        await dbHelper.insertUser(newUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context); //Powrót do ekranu logowania
      } catch (e) {
        //Obsługa błędu, gdy nazwa użytkownika lub adres e-mail już istnieją
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username or email already exists')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an Account'),
      ),
      body: SingleChildScrollView(

        child: Center(
          child:Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            const Text(

          'Sign Up to Create an Account',
          style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: appColor,
          ),
          textAlign: TextAlign.center,
          ),
         SizedBox(height:32.0),
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
                padding: EdgeInsets.all(16),
                child: Icon(Icons.person),
                ),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
              ),
              SizedBox(height: 16.0),
              // Pole tekstowe dla pinu
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.email),
                ),
              ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an e-mail' : null,
              ),
              SizedBox(height: 16.0),
              //Pole tekstowe dla adresu email
              TextFormField(
                controller: _pinController,
                decoration: InputDecoration(
                hintText: 'PIN',
                prefixIcon: Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.lock),
                ),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a PIN' : null,
              ),
              SizedBox(height: 32.0),
              //Przycisk rejestracji użytkownika - sign up
              ElevatedButton(
                onPressed: _signup,
                child: Text('Login', style: TextStyle(color: Colors.white),
                ),
                style:buttonStyle1,
              ),
            SizedBox(height: 16.0),
            HaveAccountCheck(
            login: false,
            press: (){
              Navigator.pop(context);
            },
            ),
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
