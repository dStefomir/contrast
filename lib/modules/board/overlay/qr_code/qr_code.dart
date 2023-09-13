import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Dialog height
const double dialogHeight = 550;

/// Renders a Qr code dialog for sharing the website
class QrCodeDialog extends HookConsumerWidget {

  const QrCodeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ShadowWidget(
    key: const Key('QrCodeDialogShadowWidget'),
    offset: const Offset(0, 0),
    blurRadius: 4,
    child: Container(
        key: const Key('QrCodeDialogTopContainer'),
      color: Colors.white,
      height: dialogHeight,
      child: Column(
        key: const Key('QrCodeDialogTopColumn'),
        children: [
          Column(
            key: const Key('QrCodeDialogFirstInnerColumn'),
            children: [
              Padding(
                key: const Key('QrCodeDialogFirstInnerPadding'),
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    key: const Key('QrCodeDialogFirstInnerRow'),
                    children: [
                      StyledText(
                          key: const Key('QrCodeDialogHeaderText'),
                          text: FlutterI18n.translate(context, 'Share Contrastus'),
                          weight: FontWeight.bold
                      ),
                      const Spacer(key: Key('QrCodeDialogHeaderSpacer'),),
                      DefaultButton(
                          key: const Key('QrCodeDialogHeaderCloseButton'),
                          onClick: () => ref.read(overlayVisibilityProvider(const Key('qr_code')).notifier).setOverlayVisibility(false),
                          tooltip: FlutterI18n.translate(context, 'Close'),
                          color: Colors.black,
                          borderColor: Colors.white,
                          icon: 'close.svg'
                      ),
                    ]
                ),
              ),
              const Divider(
                  key: Key('QrCodeDialogHeaderDivider'),
                  color: Colors.black
              )
            ],
          ),
          Column(
            key: const Key('QrCodeDialogBodyColumn'),
            children: [
              Padding(
                key: const Key('QrCodeDialogBodyFirstPadding'),
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  key: const Key('QrCodeDialogBodyInnerColumn'),
                  children: [
                    StyledText(
                        key: const Key('QrCodeDialogBodyText'),
                        text: '"${FlutterI18n.translate(context, 'The future belongs to those who believe in the beauty of their dreams')}",',
                        fontSize: 10,
                        clip: false,
                        color: Colors.black87,
                        padding: 0
                    ),
                    Padding(
                      key: const Key('QrCodeDialogBodyPadding'),
                      padding: const EdgeInsets.only(top: 8),
                      child: StyledText(
                          key: const Key('QrCodeDialogBodyAuthorText'),
                          text: FlutterI18n.translate(context, 'Eleanor Roosevelt'),
                          fontSize: 10,
                          clip: false,
                          color: Colors.black87,
                          weight: FontWeight.bold,
                          padding: 0
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                key: const Key('QrCodeDialogBodyQrPadding'),
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10, top: 10),
                child: QrImageView(
                  key: const Key('QrCodeDialogBodyQrCode'),
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