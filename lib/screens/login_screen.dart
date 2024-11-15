import 'package:flutter/material.dart';
//import 'signup_screen.dart';
import 'login_form.dart';
//import 'have_account_check.dart';

///Klasa przedstawiająca ekran logowania użytkownika.
///
///Zawiera formularz logowania.
  class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

  ///Metoda budująca interfejs użytkownika ekranu logowania.
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Login', style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary),
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

