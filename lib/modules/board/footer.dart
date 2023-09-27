import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/shape.dart';
import 'package:contrast/common/widgets/tab.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/common/widgets/tooltip.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/snack.dart';

/// Renders the footer of the board page
class BoardPageFooter extends HookConsumerWidget {

  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const BoardPageFooter({super.key, required this.onUserAction});

  /// Renders the about me in the bottom tab bar
  Widget _renderAboutMe(BuildContext context, WidgetRef ref) => CustomPaint(
    key: const Key('AboutMeCustomPaint'),
    painter: HouseShadowPainter(),
    child: ClipPath(
      key: const Key('AboutMeClipPath'),
      clipper: HouseShape(),
      child: Container(
        key: const Key('AboutMeContainer'),
        width: 120,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage('assets/profile_background.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        height: boardPadding + 22,
        child: StyledTooltip(
          key: const Key('AboutMeTooltip'),
          text: FlutterI18n.translate(context, 'Menu'),
          child: Padding(
            key: const Key('AboutMePadding'),
            padding: const EdgeInsets.all(20),
            child: SpeedDial(
                key: const Key('AboutMeSpeedDial'),
                animatedIcon: AnimatedIcons.menu_home,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                animatedIconTheme: const IconThemeData(size: 50),
                shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                direction: SpeedDialDirection.up,
                animationDuration: const Duration(milliseconds: 500),
                elevation: 10,
                spacing: 5,
                spaceBetweenChildren: 10,
                children: [
                  SpeedDialChild(
                      key: const Key('AboutMeSpeedDialInstagram'),
                      foregroundColor: Colors.black,
                      labelBackgroundColor: Colors.white,
                      labelWidget: Padding(
                        key: const Key('AboutMeSpeedDialInstagramPadding'),
                        padding: const EdgeInsets.all(10.0),
                        child: ShadowWidget(
                          key: const Key('AboutMeSpeedDialInstagramShadowWidget'),
                          offset: const Offset(0, 0),
                          blurRadius: 1,
                          shadowSize: 0.1,
                          child: Container(
                            key: const Key('AboutMeSpeedDialInstagramContainer'),
                            color: Colors.white,
                            child: StyledText(
                              key: const Key('AboutMeSpeedDialInstagramText'),
                              text: FlutterI18n.translate(context, 'Instagram'),
                              padding: 5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      child: const IconRenderer(
                        key: Key('InstagramSvg'),
                        asset: 'instagram.svg',
                        color: Colors.black,
                        height: 20,
                      ),
                      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 1,
                      onTap: () async {
                        final Uri url = Uri.parse('https://www.instagram.com/dstefomir/');
                        if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                        }
                      }
                  ),
                  SpeedDialChild(
                      key: const Key('AboutMeSpeedDialShare'),
                      foregroundColor: Colors.black,
                      labelBackgroundColor: Colors.white,
                      labelWidget: Padding(
                        key: const Key('AboutMeSpeedDialSharePadding'),
                        padding: const EdgeInsets.all(10.0),
                        child: ShadowWidget(
                          key: const Key('AboutMeSpeedDialShareShadowWidget'),
                          offset: const Offset(0, 0),
                          blurRadius: 1,
                          shadowSize: 0.1,
                          child: Container(
                            key: const Key('AboutMeSpeedDialShareContainer'),
                            color: Colors.white,
                            child: StyledText(
                              key: const Key('AboutMeSpeedDialShareText'),
                              text: FlutterI18n.translate(context, 'Share'),
                              padding: 5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      child: const IconRenderer(
                        key: Key('ShareSvg'),
                        asset: 'share.svg',
                        color: Colors.black,
                        height: 20,
                      ),
                      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 1,
                      onTap: () => onUserAction(
                          ref,
                              () => Clipboard.setData(
                                  const ClipboardData(text: 'https://www.dstefomir.eu')
                              ).then((_) => showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Copied to clipboard')))
                      )
                  ),
                  SpeedDialChild(
                      key: const Key('AboutMeSpeedDialQrCode'),
                      foregroundColor: Colors.black,
                      labelBackgroundColor: Colors.white,
                      labelWidget: Padding(
                        key: const Key('AboutMeSpeedDialQrCodePadding'),
                        padding: const EdgeInsets.all(10.0),
                        child: ShadowWidget(
                          key: const Key('AboutMeSpeedDialQrCodeShadowWidget'),
                          offset: const Offset(0, 0),
                          blurRadius: 1,
                          shadowSize: 0.1,
                          child: Container(
                            key: const Key('AboutMeSpeedDialQrCodeContainer'),
                            color: Colors.white,
                            child: StyledText(
                              key: const Key('AboutMeSpeedDialQrCodeText'),
                              text: FlutterI18n.translate(context, 'Qr code'),
                              padding: 5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      child: const IconRenderer(
                        key: Key('QrCodeSvg'),
                        asset: 'qr_code.svg',
                        color: Colors.black,
                        height: 20,
                      ),
                      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 1,
                      onTap: () {
                        if(ref.read(overlayVisibilityProvider(const Key('qr_code'))) == true) {
                          ref.read(overlayVisibilityProvider(const Key('qr_code')).notifier).setOverlayVisibility(false);
                        } else {
                          ref.read(overlayVisibilityProvider(const Key('qr_code')).notifier).setOverlayVisibility(true);
                        }
                      }
                  )
                ]
            ).translateOnPhotoHover,
          ),
        ),
      ),
    ),
  );

  /// Renders the mobile layout
  Widget _renderMobileLayout(BuildContext context, WidgetRef ref, String currentTab) => Stack(
    key: const Key('FooterMobileLayoutStack'),
    children: [
      Align(
        key: const Key('FooterMobileLayoutStackAlign'),
        alignment: Alignment.bottomCenter,
        child: ShadowWidget(
          key: const Key('FooterMobileLayoutStackShadowWidget'),
          offset: const Offset(0, -2),
          blurRadius: 2,
          child: Container(
            key: const Key('FooterMobileLayoutStackContainer'),
            height: boardPadding,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              key: const Key('FooterMobileLayoutStackRow'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  key: const Key('FooterMobileLayoutStackExpandedPhoto'),
                  child: StyledTooltip(
                    key: const Key('FooterMobileLayoutPhotoTooltip'),
                    text: FlutterI18n.translate(context, 'Photographs'),
                    child: Material(
                      key: const Key('FooterMobileLayoutPhotoMaterial'),
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('FooterMobileLayoutPhotoInk'),
                        onTap: () => ref.read(boardFooterTabProvider.notifier).switchTab('photos'),
                        child: Container(
                            key: const Key('FooterMobileLayoutPhotoContainer'),
                          height: boardPadding,
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: currentTab == 'photos' ? Colors.black: Colors.white,
                          ),
                          child: IconRenderer(
                            key: const Key('FooterMobileLayoutPhotoSvg'),
                            asset: 'photo.svg',
                            color: currentTab == 'photos' ? Colors.white: Colors.black,
                            height: 50,
                          )
                        ),
                      ),
                    ).translateOnPhotoHover,
                  ),
                ),
                const SizedBox(key: Key('FooterMobileLayoutSizedBox'), width: 120),
                Expanded(
                  key: const Key('FooterMobileLayoutStackExpandedVideo'),
                  child: StyledTooltip(
                    key: const Key('FooterMobileLayoutVideoTooltip'),
                    text: FlutterI18n.translate(context, 'Videos'),
                    child: Material(
                      key: const Key('FooterMobileLayoutVideoMaterial'),
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('FooterMobileLayoutVideoInk'),
                        onTap: () => ref.read(boardFooterTabProvider.notifier).switchTab('videos'),
                        child: Container(
                          key: const Key('FooterMobileLayoutVideoContainer'),
                          height: boardPadding,
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: currentTab == 'videos' ? Colors.black: Colors.white,
                          ),
                          child: IconRenderer(
                              key: const Key('FooterMobileLayoutVideoSvg'),
                              asset: 'video.svg',
                              color: currentTab == 'videos' ? Colors.white: Colors.black,
                              height: 50
                          ),
                        ),
                      ),
                    ).translateOnPhotoHover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Align(
        key: const Key('FooterMobileLayoutAboutMeAlign'),
        alignment: Alignment.bottomCenter,
        child: _renderAboutMe(context, ref).translateOnPhotoHover,
      ),
    ],
  );

  /// Renders the desktop layout
  Widget _renderDesktopLayout(BuildContext context, WidgetRef ref, String currentTab) => Stack(
    key: const Key('FooterDesktopLayoutStack'),
    children: [
      Align(
        key: const Key('FooterDesktopLayoutStackAlign'),
        alignment: Alignment.bottomCenter,
        child: ShadowWidget(
          key: const Key('FooterDesktopLayoutShadowWidget'),
          offset: const Offset(0, -2),
          blurRadius: 2,
          child: Container(
            key: const Key('FooterDesktopLayoutStackContainer'),
            height: boardPadding,
            color: Colors.white,
            child: Stack(
              key: const Key('FooterDesktopLayoutInnerStack'),
              children: [
                Container(
                  key: const Key('FooterDesktopLayoutBackgroundGradient'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.10),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                Align(
                  key: const Key('FooterDesktopLayoutStackInnerAlign'),
                  alignment: Alignment.center,
                  child: Row(
                    key: const Key('FooterDesktopLayoutStackRow'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(key: Key('FooterDesktopLayoutStackPhotoEmptySpacer')),
                      ContrastTab(
                          widgetKey: const Key('photos'),
                          tabKey: 'photos',
                          text: FlutterI18n.translate(context, 'photos'),
                          onClick: (String tab) => ref.read(boardFooterTabProvider.notifier).switchTab(tab),
                          isSelected: currentTab == 'photos'
                      ).translateOnPhotoHover,
                      const Spacer(key: Key('FooterDesktopLayoutPhotosSpacer')),
                      const SizedBox(key: Key('FooterDesktopLayoutAboutMeSizedBox'), width: 160),
                      const Spacer(key: Key('FooterDesktopLayoutVideosSpacer')),
                      ContrastTab(
                          widgetKey: const Key('videos'),
                          tabKey: 'videos',
                          text: FlutterI18n.translate(context, 'videos'),
                          onClick: (String tab) => ref.read(boardFooterTabProvider.notifier).switchTab(tab),
                          isSelected: currentTab == 'videos'
                      ).translateOnPhotoHover,
                      const Spacer(key: Key('FooterDesktopLayoutStackVideosEmptySpacer')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Align(
        key: const Key('FooterDesktopLayoutAboutMeAlign'),
        alignment: Alignment.bottomCenter,
        child: _renderAboutMe(context, ref).translateOnPhotoHover,
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentTab = ref.watch(boardFooterTabProvider);

    return useMobileLayout(context)
        ? _renderMobileLayout(context, ref, currentTab)
        : _renderDesktopLayout(context, ref, currentTab);
  }
}
