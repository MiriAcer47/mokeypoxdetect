import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/user.dart';
import 'patient_list.dart';
import '../styles.dart';


//Klasa przedstawiająca ekran logowania. W celu zalogowania użytkownik podaje nazwe użytkownika oraz PIN.
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(); //kontoler pola nazwy użytkownika
  final _pinController = TextEditingController(); //kontoler pola PIN
  final dbHelper = DatabaseHelper.instance;

  //metoda logowania użytkownika
  void _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      String pin = _pinController.text.trim();

      User? user = await dbHelper.getUser(username);
      if (user != null && user.pin == pin) {
        //Jeśli dane są poprawne przejdź do listy pacjentów
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientList()),
        );
      } else {
        //W przypadku niepoprawnie wprowadzonych danych wyświetl komunikat o błędzie
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or PIN')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: [
          //Pola tekstowe dla nazwy użytkownika
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Username',
              prefixIcon: Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.person),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter your username' : null,
          ),
          SizedBox(height: 16.0),
          //Pola tekstowe dla PIN
          TextFormField(
            controller: _pinController,
            decoration: InputDecoration(
              hintText: 'PIN',
              prefixIcon: Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.lock),
              ),
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            validator: (value) =>
            value!.isEmpty ? 'Please enter your PIN' : null,
          ),
          SizedBox(height: 32),
          //Przycisk logowania
          ElevatedButton(
            onPressed: _login,
            child: Text('Login', style: TextStyle(color: Colors.white),
            ),
            style:buttonStyle1,
          ),
        ],
      ),
    );
  }
}

class HaveAccountCheck extends StatelessWidget{
  final bool login;
  final VoidCallback press;

  const HaveAccountCheck({
    Key? key,
    this.login = true,
    required this.press,
  }) :super(key:key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          login ? "Don't have an account? " : "Already have an account? ",
          style: TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? "Sign Up" : "Sign In",
            style: TextStyle(
              color: appColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
