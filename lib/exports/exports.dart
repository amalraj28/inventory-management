import 'package:flutter/material.dart';

createSnackbar(
    {required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white}) {
  final snackbar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: textColor),
    ),
    backgroundColor: backgroundColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
