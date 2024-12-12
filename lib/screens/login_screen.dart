import 'package:flutter/material.dart';
//import 'signup_screen.dart';
import 'login_form.dart';
//import 'have_account_check.dart';

///Klasa przedstawiająca ekran logowania użytkownika.
///
///Zawiera formularz logowania.
class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

  ///Wyświetla okno sialogowe z informacją o aplikacji.
  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Information'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const<Widget>[
              Text('Application Name: MonkeyPoxDetect', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Version: 1.0.0'),
              SizedBox(height: 10),
              Text('Author: Miriam Reca', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'Description: This application allows users to take photos of skin lesions and predicts whether they indicate Mpox disease. The goal of this app is to provide a faster and more accurate diagnostic tool to support medical services.',
              ),
              SizedBox(height: 10),
            ],
          )
        ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ///Metoda budująca interfejs użytkownika ekranu logowania.
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              'User Login', style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary)),
          backgroundColor: colorScheme.primary,
        actions: <Widget>[
         IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInfo(context); // Użyj _showCupertinoInfoDialog(context) dla stylu Cupertino
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40.0),
                //Obraz na ekranie logowania.
                Image.asset(
                    'assets/images/img22_loginscreen.png',
                    height: 200.0),
                const SizedBox(height: 20.0),
                Text(
                  'Enter your login and PIN',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    //color: colorScheme.onSurface,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48.0),
                const LoginForm(),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

