import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

/// Renders a cookie submit dialog
class CookieWarningDialog extends StatelessWidget {
  /// What happens when the user submits the cookie form.
  final void Function() onSubmit;

  const CookieWarningDialog({required this.onSubmit, super.key});

  @override
  Widget build(BuildContext context) =>
      Align(
        alignment: FractionalOffset.bottomLeft,
        child: Container(
          margin: EdgeInsets.only(
              left: useMobileLayoutOriented(context) ? 0 : 10.0,
              bottom: useMobileLayoutOriented(context) ? 0 : 10.0
          ),
          child: Material(
            elevation: 18.0,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StyledText(
                    text: translate('Cookie Warning'),
                    color: Colors.black,
                    useShadow: false,
                    fontSize: 20,
                    weight: FontWeight.bold,
                  ),
                  StyledText(
                    text: translate('This website uses cookies to ensure you get the best experience'),
                    color: Colors.black,
                    useShadow: false,
                    fontSize: 13,
                    align: TextAlign.start,
                    clip: false,
                  ),
                  const SizedBox(height: 10.0),
                  NormalButton(
                      widgetKey: const Key('Submit cookie'),
                      onClick: () => onSubmit(),
                      text: translate('Alright')
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
