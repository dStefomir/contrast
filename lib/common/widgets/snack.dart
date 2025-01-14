import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:flutter/material.dart';

/// Renders an error snack bar on the screen
void showErrorTextOnSnackBar(BuildContext? context, String text) {
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 3500),
        content: SizedBox(
          height: boardPadding,
          child: Center(
            child: StyledText(
              text: text,
              padding: 0,
              fontSize: 15,
              clip: false,
              weight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Renders an successful snack bar on the screen
void showSuccessTextOnSnackBar(BuildContext? context, String text) {
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 3500),
        content: SizedBox(
          height: boardPadding,
          child: Center(
            child: StyledText(
              text: text,
              padding: 0,
              fontSize: 15,
              clip: false,
              weight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.grey[100],
      ),
    );
  }
}
