import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'material_theme.dart';

/// Główna funkcja uruchamiająca aplikację Flutter.
void main() {
  runApp(const MonkeypoxDetectApp()); // uruchomienie aplikacji
}

/// Główna klasa aplikacji zarządzająca jej stanem.
class MonkeypoxDetectApp extends StatelessWidget {
  const MonkeypoxDetectApp({super.key});

  ///Metoda budująca interfejs, ustawiająca motywy aplikacji (jasny/ciemny) oraz początkowy ekran.
  @override
  Widget build(BuildContext context) {
    //Instancja MaterialTheme z wygenerowanym schematem kolorów
    final materialTheme = MaterialTheme(TextTheme());

    return MaterialApp(
      title: 'MonkeyPox Detect', // Tytuł aplikacji

      //Motyw dla jasnego trybu
      theme: materialTheme.light(),

      //Motyw dla ciemnego trybu
      darkTheme: materialTheme.dark(),

      //Przełączanie między trybami
      themeMode: ThemeMode.system,

      // Początkowy ekran aplikacji
      home: WelcomeScreen(),
    );
  }
}
