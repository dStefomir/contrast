import 'package:flutter/material.dart';

/// Renders an error snack bar on the screen
void showErrorTextOnSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    ),
  );
}

/// Renders an successful snack bar on the screen
void showSuccessTextOnSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.grey[50],
    ),
  );
}
