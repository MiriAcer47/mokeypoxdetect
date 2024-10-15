import 'package:flutter/material.dart';

//Kolory aplikacji
const Color appColor = Color(0xFF8DB6FF);
const Color pressedColor = Color(0xFF7096D9);

//Style przycisków
final ButtonStyle buttonStyle1 = ElevatedButton.styleFrom(
  backgroundColor: appColor,
  foregroundColor: Colors.white,
  minimumSize: Size(150, 50),
  padding: EdgeInsets.symmetric(horizontal: 16),
  textStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'Inter',
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle buttonStyle2 = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: appColor,
  minimumSize: Size(150, 50),
  padding: EdgeInsets.symmetric(horizontal: 16),
  textStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'Inter',
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    side: BorderSide(color: appColor, width: 2),
  ),
);

//Styl dla tekstu nagłówka
const TextStyle headerTextStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  fontFamily: 'Inter',
);
