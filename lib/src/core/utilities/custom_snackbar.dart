import 'package:flutter/material.dart';

void showCustomSnackBar({required BuildContext context, required String message, required Color color, VoidCallback? action}) {

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(20),
    backgroundColor: color,

    // content: const Text('Yay! A SnackBar!'),
    // action: SnackBarAction(
    //   label: 'Undo',
    //   onPressed: () {
    //     // Some code to undo the change.
    //   },
    // ),

    content: Text(message),
    action: action != null
    ? SnackBarAction(
      label: 'Undo',
      onPressed: action,
    )
    : null,
    
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

}