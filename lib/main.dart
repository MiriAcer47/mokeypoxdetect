import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

///Stała koloru aplikacji używana jako główny kolor motywu.
const Color appColor = Color(0xFF8DB6FF);

///Kolor przycisku podczas jego naciśnięcia.
const Color pressedColor = Color(0xFF7096D9);

///Mapa kolorów do tworzenia niestandardowego koloru MaterialColor.
Map<int, Color> color =
{
  50: Color.fromRGBO(141, 182, 255, .1),
  100: Color.fromRGBO(141, 182, 255, .2),
  200: Color.fromRGBO(141, 182, 255, .3),
  300: Color.fromRGBO(141, 182, 255, .4),
  400: Color.fromRGBO(141, 182, 255, .5),
  500: Color.fromRGBO(141, 182, 255, .6),
  600: Color.fromRGBO(141, 182, 255, .7),
  700: Color.fromRGBO(141, 182, 255, .8),
  800: Color.fromRGBO(141, 182, 255, .9),
  900: Color.fromRGBO(141, 182, 255, 1),
};

///Niestandardowy kolor MaterialColor uzyskany na podstawie mapy kolorów.
MaterialColor customSwatch = MaterialColor(0xFF8DB6FF, color);


///Główna funkcja uruchamiająca aplikację Flutter.
void main() {
  runApp(const MonkeypoxDetectApp()); // uruchomienie aplikacji
}

///Główna klasa aplikacji zarządzająca jej stanem.
class MonkeypoxDetectApp extends StatelessWidget {
  const MonkeypoxDetectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonkeyPox Detect', // tytuł aplikacji

      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: customSwatch, //Niestandardowy kolor primarySwatch
        fontFamily: 'Inter',

        ///Styl dla paska narzędzi AppBar.
        appBarTheme: AppBarTheme(
          color: appColor, // Kolor paska narzędzi
          foregroundColor: Colors.white, //Kolor tekstu na pasku narzędzi
        ),


        /// Styl dla przycisków ElevatedButton.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  //Jeśli przycisk jest wciśnięty - zmiana koloru
                  return pressedColor;
                }
                return appColor;// Domyślny kolor przycisku
              },
            ),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            // Efekt cienia przycisku
            elevation: MaterialStateProperty.resolveWith<double>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return 0; // Brak cienia podczas naciskania
                }
                return 2; // Wysokość cienia
              },
            ),
          ),
        ),



        ///Styl dla pól tekstowych TextField.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),

      ),
      home: WelcomeScreen(), // Ekran początkowy aplikacji
    );
  }
}

