import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CCupertinoAlertDialog extends StatelessWidget{
  final  String title;
  final String content;
  final VoidCallback onConfirm;

  CCupertinoAlertDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
  });


  @override
  Widget build(BuildContext context){
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text('Yes'),
          isDefaultAction: true,
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
          isDestructiveAction: true,
        ),
      ],
    );

  }
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