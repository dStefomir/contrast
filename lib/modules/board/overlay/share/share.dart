import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/widgets/snack.dart';

/// Dialog height
const double dialogHeight = 400;

/// Renders a dialog for sharing the website/apps
class ShareDialog extends HookConsumerWidget {

  const ShareDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ShadowWidget(
    offset: const Offset(0, 0),
    blurRadius: 4,
    child: Container(
        color: Colors.white,
        height: dialogHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    children: [
                      StyledText(
                          text: FlutterI18n.translate(context, 'Share Contrastus'),
                          weight: FontWeight.bold
                      ),
                      const Spacer(),
                      DefaultButton(
                          onClick: () => ref.read(overlayVisibilityProvider(const Key('share')).notifier).setOverlayVisibility(false),
                          tooltip: FlutterI18n.translate(context, 'Close'),
                          color: Colors.white,
                          borderColor: Colors.black,
                          icon: 'close.svg'
                      ),
                    ]
                ),
              ),
              const Divider(color: Colors.black),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  IconRenderer(asset: 'background_landscape.svg', height: dialogHeight / 1.4, color: Colors.black.withOpacity(0.05), fit: BoxFit.cover),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: DefaultButton(
                            shape: BoxShape.circle,
                            tooltip: FlutterI18n.translate(context, 'Website'),
                            onClick: () => Clipboard.setData(
                                const ClipboardData(text: 'https://www.dstefomir.eu')
                            ).then((value) => showSuccessTextOnSnackBar(
                                context,
                                FlutterI18n.translate(context, 'Copied to clipboard')
                            )),
                            borderColor: Colors.transparent,
                            borderWidth: 5,
                            height: 100,
                            icon: 'chrome.svg'
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DefaultButton(
                              shape: BoxShape.circle,
                              tooltip: FlutterI18n.translate(context, 'Google Play Store'),
                              onClick: () => Clipboard.setData(
                                  const ClipboardData(text: 'https://play.google.com/store/apps/details?id=eu.bsdsoft.contrast')
                              ).then((value) => showSuccessTextOnSnackBar(
                                  context,
                                  FlutterI18n.translate(context, 'Copied to clipboard')
                              )),
                              borderColor: Colors.transparent,
                              padding: 25,
                              height: 100,
                              icon: 'play_store.svg'
                          ),
                          const SizedBox(width: 20),
                          DefaultButton(
                              shape: BoxShape.circle,
                              tooltip: FlutterI18n.translate(context, 'Apple App Store'),
                              onClick: () => Clipboard.setData(
                                  const ClipboardData(text: 'https://apps.apple.com/bg/app/contrastus/id6466247842')
                              ).then((value) => showSuccessTextOnSnackBar(
                                  context,
                                  FlutterI18n.translate(context, 'Copied to clipboard')
                              )),
                              borderColor: Colors.transparent,
                              padding: 25,
                              height: 100,
                              icon: 'app_store.svg'
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
    ),
  );
}