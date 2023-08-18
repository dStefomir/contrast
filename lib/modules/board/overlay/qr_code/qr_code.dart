import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Dialog height
const double dialogHeight = 550;

/// Renders a Qr code dialog for sharing the website
class QrCodeDialog extends HookConsumerWidget {

  const QrCodeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ShadowWidget(
    offset: const Offset(0, 0),
    blurRadius: 4,
    child: Container(
      color: Colors.white,
      height: dialogHeight,
      child: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    children: [
                      const StyledText(text: "Share Contrast", weight: FontWeight.bold),
                      const Spacer(),
                      DefaultButton(
                          onClick: () => ref.read(overlayVisibilityProvider(const Key('qr_code')).notifier).setOverlayVisibility(false),
                          color: Colors.black,
                          borderColor: Colors.white,
                          icon: 'close.svg'
                      ),
                    ]
                ),
              ),
              const Divider(color: Colors.black,)
            ],
          ),
          Column(
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
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10, top: 10),
                child: QrImageView(
                  padding: EdgeInsets.zero,
                  data: 'https://www.dstefomir.eu',
                  version: QrVersions.auto,
                  size: 350,
                ),
              ),
            ],
          ),
        ],
      )
    ),
  );
}