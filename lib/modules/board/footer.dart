import 'dart:html' as html;

import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/shape.dart';
import 'package:contrast/common/widgets/tab.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the footer of the board page
class BoardPageFooter extends HookConsumerWidget {

  const BoardPageFooter({super.key});

  /// Renders the about me in the bottom tab bar
  Widget _renderAboutMe() => CustomPaint(
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
        height: desktopBottomPadding + 22,
        child: Padding(
          padding: const EdgeInsets.only(top: 35, bottom: 20, left: 20, right: 20),
          child: StyledButton(
            widgetKey: const Key('about'),
            onClick: () => html.window.open('https://www.instagram.com/dstefomir/', '_blank'),
            iconAsset: 'instagram.svg',
            iconHeight: 30,
            shadow: false,
            onlyIcon: true,
            iconColor: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    ),
  );

  /// Renders the mobile layout
  Widget _renderMobileLayout(WidgetRef ref, String currentTab) => Stack(
    children: [
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: mobileMenuWidth,
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
                child: Container(
                  height: mobileMenuIconSize,
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: currentTab == 'photos' ? Colors.black: Colors.white,
                  ),
                  child: StyledButton(
                      widgetKey: const Key('photos'),
                      onlyIcon: true,
                      shadow: false,
                      onClick: () => ref.read(boardFooterTabProvider.notifier).switchTab('photos'),
                      iconAsset: 'photo.svg',
                      iconColor: currentTab == 'photos' ? Colors.white: Colors.black
                  ),
                ),
              ),
              const SizedBox(width: 120),
              Expanded(
                child: Container(
                  height: mobileMenuIconSize,
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: currentTab == 'videos' ? Colors.black: Colors.white,
                  ),
                  child: StyledButton(
                      widgetKey: const Key('videos'),
                      onlyIcon: true,
                      shadow: false,
                      onClick: () => ref.read(boardFooterTabProvider.notifier).switchTab('videos'),
                      iconAsset: 'youtube.svg',
                      iconColor: currentTab == 'videos' ? Colors.white: Colors.black
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: _renderAboutMe().translateOnPhotoHover,
      ),
    ],
  );

  /// Renders the desktop layout
  Widget _renderDesktopLayout(WidgetRef ref, String currentTab) => Stack(
    children: [
      Align(
        alignment: Alignment.bottomCenter,
        child: ShadowWidget(
          offset: const Offset(0, -2),
          blurRadius: 2,
          child: Container(
            height: desktopBottomPadding,
            color: Colors.white,
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.center,
                    child: RotatedBox(
                        quarterTurns: 2,
                        child: IconRenderer(
                            asset: 'background_picture.jpg',
                            fit: BoxFit.cover,
                            color: Colors.black.withOpacity(0.05)
                        )
                    )
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
        child: _renderAboutMe().translateOnPhotoHover,
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentTab = ref.watch(boardFooterTabProvider);

    return useMobileLayout(context)
        ? _renderMobileLayout(ref, currentTab)
        : _renderDesktopLayout(ref, currentTab);
  }
}
