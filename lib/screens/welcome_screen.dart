import 'package:flutter/material.dart';
import 'login_screen.dart';

///Klasa reprezentująca ekran startowy aplikacji.
///Ekran z logiem, tesktem startowym oraz przejściem do ekranu logowania.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  ///Metoda budująca interfejs ekranu startowego.
  @override
  Widget build(BuildContext context) {
    //Pobranie schematu kolrów.
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      //Tło ekranu
      body: Container(
        color: colorScheme.primary,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo
                Image.asset(
                  'assets/images/img1_logo.png',
                  height: 180.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 50),
                //Tekst powitalny aplikacji
                Text(
                  'Welcome to MonkeyPoxDetect!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                //Tekst opisujący aplikację
                Text(
                  'Take a photo of your skin lesion and get the results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 150),

                //Przycisk przejścia do ekranu logowania
                FilledButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    backgroundColor: colorScheme.onPrimary,
                    //side: BorderSide(color: colorScheme.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ).copyWith(
                    //Zmiana kolru podczas naciśnięcia przycisku.
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return colorScheme.primary;
                          }
                          return colorScheme.onPrimary;
                        }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return colorScheme.onPrimary;
                          }
                          return colorScheme.primary;
                        }),
                    side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return BorderSide(color: colorScheme.onPrimary, width: 1.5);
                      }
                      return BorderSide(color: colorScheme.primary, width: 1.5);
                    }),
                    elevation: MaterialStateProperty.resolveWith<double>((states) {
                      if (states.contains(MaterialState.pressed)) return 8;
                      return 4;
                    }),
                  ),
                  child: const Text(
                    'GET STARTED',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
