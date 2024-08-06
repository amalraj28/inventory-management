import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

String formatName(String? name) {
  if (name == null) return '';
  return name.toUpperCase();
}

String formatAddress(String? address,
    {String replaceWhom = ' ', String replaceWith = '\n'}) {
  if (address == null) return '';
  return address.replaceAll(RegExp(replaceWhom), replaceWith);

}

final OUR_NAME = formatName(dotenv.env['OUR_NAME']);
final OUR_ADDRESS = formatAddress(dotenv.env['OUR_ADDRESS'],
    replaceWhom: '__', replaceWith: ', ');
final OUR_WEBSITE = dotenv.env['OUR_WEBSITE'] ?? '';
