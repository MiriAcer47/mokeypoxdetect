import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Klasa reprezentujaća okno do wyświetlania Alertów w stylu Cupertino.
///
///Umożliwia wyświetlanie okna do potwierdzania lub anulowania akcji.
class CCupertinoAlertDialog extends StatelessWidget{
 ///Tytył okna dialogowego.
  final  String title;

  ///Treść okna dialogowego.
  final String content;

  ///Funkcja wywołana po potwierdzeniu akcji.
  final VoidCallback onConfirm;

  ///Konstruktor klasy `CCupertinoAlertDialog`.
  ///
  /// Parametry:
  /// - [title]: Tytuł okna dialogowego.
  /// - [content]: Treść okna dialogowego.
  /// - [onConfirm]: Funkcja wywoływana po potwierdzeniu.
  const CCupertinoAlertDialog({super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

///Buduje interfejs użytkownika okna dialogowego.
  @override
  Widget build(BuildContext context){
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        ///Akcja potwierdzenia.
        CupertinoDialogAction(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          isDefaultAction: true,
          child: const Text('Yes'),
        ),

        ///Akcja anulowania.
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  ///Metoda statyczna wyświetlająca okno dialogowe.
  ///
  /// Parametry:
  /// - [context]: Kontekst aplikacji.
  /// - [title]: Tytuł okna dialogowego.
  /// - [content]: Treść okna dialogowego.
  /// - [onConfirm]: Funkcja wywołana po potwierdzeniu.
  ///
  /// Zwraca:
  /// - `Future<void>` reprezentujące operację wyświetlania dialogu.
  static Future<void> show ({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }){
    return showDialog(
      context: context,
      builder: (context){
        return CCupertinoAlertDialog(title: title, content: content, onConfirm: onConfirm);
      },
    );
  }
}