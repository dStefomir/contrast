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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/snack.dart';

/// Renders the footer of the board page
class BoardPageFooter extends HookConsumerWidget {

  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const BoardPageFooter({super.key, required this.onUserAction});

  /// Renders the about me in the bottom tab bar
  Widget _renderAboutMe(BuildContext context, WidgetRef ref) => CustomPaint(
    painter: HouseShadowPainter(),
    child: ClipPath(
      clipper: HouseShape(),
      child: Container(
        width: 120,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage('assets/profile.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        height: boardPadding + 22,
        child: StyledTooltip(
          text: 'Menu',
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SpeedDial(
                animatedIcon: AnimatedIcons.menu_home,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white.withOpacity(0.5),
                animatedIconTheme: const IconThemeData(size: 50),
                shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                direction: SpeedDialDirection.up,
                buttonSize: const Size(80, 0),
                elevation: 1,
                spacing: 5,
                spaceBetweenChildren: 10,
                children: [
                  SpeedDialChild(
                      foregroundColor: Colors.black,
                      labelBackgroundColor: Colors.white,
                      child: const StyledTooltip(
                        text: 'Instagram',
                        pointingPosition: AxisDirection.right,
                        child: IconRenderer(
                          asset: 'instagram.svg',
                          color: Colors.black,
                          height: 20,
                        ),
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
                      foregroundColor: Colors.black,
                      labelBackgroundColor: Colors.white,
                      child: const StyledTooltip(
                        text: 'Share',
                        pointingPosition: AxisDirection.left,
                        child: IconRenderer(
                          asset: 'share.svg',
                          color: Colors.black,
                          height: 20,
                        ),
                      ),
                      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 1,
                      onTap: () => onUserAction(
                          ref,
                              () => Clipboard.setData(
                                  const ClipboardData(text: 'https://www.dstefomir.eu')
                              ).then((_) => showSuccessTextOnSnackBar(context, "Copied to clipboard"))
                      )
                  ),
                  SpeedDialChild(
                      foregroundColor: Colors.black,
                      labelBackgroundColor: Colors.white,
                      child: const StyledTooltip(
                        text: 'Qr code',
                        pointingPosition: AxisDirection.up,
                        child: IconRenderer(
                          asset: 'qr_code.svg',
                          color: Colors.black,
                          height: 20,
                        ),
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
    children: [
      Align(
        alignment: Alignment.bottomCenter,
        child: ShadowWidget(
          offset: const Offset(0, -2),
          blurRadius: 2,
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: StyledTooltip(
                    text: 'Photographs',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => ref.read(boardFooterTabProvider.notifier).switchTab('photos'),
                        child: Container(
                          height: boardPadding,
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: currentTab == 'photos' ? Colors.black: Colors.white,
                          ),
                          child: IconRenderer(
                            asset: 'photo.svg',
                            color: currentTab == 'photos' ? Colors.white: Colors.black,
                            height: 50,
                          )
                        ),
                      ),
                    ).translateOnPhotoHover,
                  ),
                ),
                const SizedBox(width: 120),
                Expanded(
                  child: StyledTooltip(
                    text: 'Videos',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => ref.read(boardFooterTabProvider.notifier).switchTab('videos'),
                        child: Container(
                          height: boardPadding,
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: currentTab == 'videos' ? Colors.black: Colors.white,
                          ),
                          child: IconRenderer(
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
        alignment: Alignment.bottomCenter,
        child: _renderAboutMe(context, ref).translateOnPhotoHover,
      ),
    ],
  );

  /// Renders the desktop layout
  Widget _renderDesktopLayout(BuildContext context, WidgetRef ref, String currentTab) => Stack(
    children: [
      Align(
        alignment: Alignment.bottomCenter,
        child: ShadowWidget(
          offset: const Offset(0, -2),
          blurRadius: 2,
          child: Container(
            height: boardPadding,
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      ContrastTab(
                          widgetKey: const Key('photos'),
                          text: 'photos',
                          onClick: (String tab) => ref.read(boardFooterTabProvider.notifier).switchTab(tab),
                          isSelected: currentTab == 'photos'
                      ).translateOnPhotoHover,
                      const Spacer(),
                      const SizedBox(width: 160),
                      const Spacer(),
                      ContrastTab(
                          widgetKey: const Key('videos'),
                          text: 'videos',
                          onClick: (String tab) => ref.read(boardFooterTabProvider.notifier).switchTab(tab),
                          isSelected: currentTab == 'videos'
                      ).translateOnPhotoHover,
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Align(
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
