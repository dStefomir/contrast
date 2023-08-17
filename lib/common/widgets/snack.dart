import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/material.dart';

/// Renders an error snack bar on the screen
void showErrorTextOnSnackBar(BuildContext context, String text) =>
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 500),
      content: StyledText(
        text: text,
        padding: 0,
        useShadow: true,
        color: Colors.black,
      ),
      backgroundColor: Colors.red,
    ),
  );

/// Renders an successful snack bar on the screen
void showSuccessTextOnSnackBar(BuildContext context, String text) =>
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 500),
      content: StyledText(
        text: text,
        padding: 0,
        useShadow: true,
        color: Colors.black,
      ),
      backgroundColor: Colors.grey[100],
    ),
  );
