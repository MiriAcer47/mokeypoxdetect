import 'package:flutter/material.dart';
import 'package:monkey/main.dart';
import 'login_screen.dart';
import '../styles.dart';

//Klasa przedstawiająca ekran początkowy aplikacji, który jest wyswietlany po uruchomieniu aplikacji
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Kolog tła
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:  [Color(0xFF7096D9), Color(0xFF8DB6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //logo
            Image.asset(
              'assets/images/img1_logo.png',
              height: 150.0,
              fit: BoxFit.contain,
            ),
          SizedBox(height: 30),
            //Tekst strony głównej
            Text(
              'Welcome to the MonkeyPoxDetect App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            //Przycisk przejścia do ekranu logowania
            ElevatedButton(
              style: buttonStyle2,
              child: Text('Get Started'),
              onPressed: () {
                //Przejście do ekranu logowania
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            SizedBox(height: 30),
            /*CircularProgressIndicator(
              color: Colors.white,
            strokeWidth: 2,
            ),*/
          ],
          ),
        ),
      ),
      ),
    );
  }
}
