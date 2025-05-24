import 'dart:io';

import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    child: SingleChildScrollView(
      child: Container(
        color: Colors.white,
        height: dialogHeight,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                        text: 'Share Contrastus'.tr(),
                        weight: FontWeight.bold
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      child: StyledText(
                          text: 'Share Contrastus with your friends'.tr(),
                          color: Colors.grey,
                          fontSize: 10,
                          padding: 0,
                          letterSpacing: 3,
                          clip: false,
                          align: TextAlign.start,
                          weight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: DefaultButton(
                      onClick: () => ref.read(overlayVisibilityProvider(const Key('qr_code')).notifier).setOverlayVisibility(false),
                      tooltip: 'Close'.tr(),
                      color: Colors.white,
                      borderColor: Colors.black,
                      icon: 'close.svg'
                  ),
                ),
              ],
            ),
            const Divider(
                color: Colors.black
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 0),
              child: QrImageView(
                padding: EdgeInsets.zero,
                data: kIsWeb ? 'https://www.dstefomir.eu' : Platform.isAndroid ? 'https://play.google.com/store/apps/details?id=eu.bsdsoft.contrast' : 'https://apps.apple.com/bg/app/contrastus/id6466247842',
                version: QrVersions.auto,
                size: 350,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
  );
}