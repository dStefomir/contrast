import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Dialog width
const double dialogWidth = 300;
/// Dialog height
const double dialogHeight = 360;

class QrCodeDialog extends StatelessWidget {

  const QrCodeDialog({super.key});

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      Navigator.of(context).pop();

      return true;
    },
    child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        title: Column(
          children: [
            Row(
                children: [
                  const StyledText(text: "Contrast", weight: FontWeight.bold),
                  const Spacer(),
                  DefaultButton(
                      onClick: () => Navigator.of(context).pop(),
                      color: Colors.black,
                      borderColor: Colors.white,
                      icon: 'close.svg'
                  ),
                ]
            ),
            const Divider(color: Colors.black,)
          ],
        ),
        content: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    StyledText(text: '"The future belongs to those who believe in the beauty of their dreams.",', fontSize: 10, clip: false, color: Colors.black87, padding: 0,),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: StyledText(text: 'Eleanor Roosevelt', fontSize: 10, clip: false, color: Colors.black87, weight: FontWeight.bold, padding: 0,),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10),
                child: QrImageView(
                  padding: EdgeInsets.zero,
                  data: 'https://www.dstefomir.eu',
                  version: QrVersions.auto,
                ),
              ),
            ],
          ),
        ),
    )
  );
}