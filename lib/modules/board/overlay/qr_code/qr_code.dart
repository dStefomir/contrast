import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Dialog width
const double dialogWidth = 200;
/// Dialog height
const double dialogHeight = 200;

class QrCodeDialog extends StatelessWidget {

  const QrCodeDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: const Center(
          child: StyledText(
              text: "Contrast",
              weight: FontWeight.bold
          )
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Center(
          child: QrImageView(
            data: 'https://www.dstefomir.eu',
            version: QrVersions.auto,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                elevation: MaterialStateProperty.all(2),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.black))
            ),
            child: const Text("Close"),
            onPressed: () => Navigator.of(context).pop()
        ),
      ]
  );
}