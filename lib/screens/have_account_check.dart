import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/user.dart';
import 'patient_list.dart';
import '../styles.dart';

///Widget do sprawdzania, czy użytkownik ma konto.
///Wyświetla opcję przejścia do ekranu rejestracji lub logowania w zleżności od stanu.
class HaveAccountCheck extends StatelessWidget{
  final bool login; //czy użytkownik jest na ekranie logowania
  final VoidCallback press; //funkcja po naciśnięciu przycisku

  const HaveAccountCheck({
    super.key,
    this.login = true,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          //Tekst wyświetlany w zależności od stanu
          login ? "Don't have an account? " : "Already have an account? ",
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        //Przycisk przejścia do ekranu logowania lub rejestracji
        GestureDetector(
          onTap: press,
          child: Text(
            login ? "Sign Up" : "Sign In",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

