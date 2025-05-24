import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialog height
const double dialogHeight = 300;

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        onClick: () => ref.read(overlayVisibilityProvider(const Key('share')).notifier).setOverlayVisibility(false),
                        tooltip: 'Close'.tr(),
                        color: Colors.white,
                        borderColor: Colors.black,
                        icon: 'close.svg'
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.black),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: DefaultButton(
                        shape: BoxShape.circle,
                        tooltip: 'Website'.tr(),
                        onClick: () async {
                          final Uri url = Uri.parse('https://www.dstefomir.eu');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        borderColor: Colors.transparent,
                        iconFit: BoxFit.cover,
                        height: 50,
                        icon: 'chrome.svg'
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultButton(
                          shape: BoxShape.circle,
                          tooltip: 'Google Play Store'.tr(),
                          onClick: () async {
                            final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=eu.bsdsoft.contrast');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          borderColor: Colors.transparent,
                          iconFit: BoxFit.cover,
                          height: 50,
                          padding: 25,
                          icon: 'play_store.svg'
                      ),
                      const SizedBox(width: 20),
                      DefaultButton(
                          shape: BoxShape.circle,
                          tooltip: 'Apple App Store'.tr(),
                          onClick: () async {
                            final Uri url = Uri.parse('https://apps.apple.com/bg/app/contrastus/id6466247842');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          borderColor: Colors.transparent,
                          iconFit: BoxFit.cover,
                          height: 50,
                          padding: 25,
                          icon: 'app_store.svg'
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        )
    ),
  );
}