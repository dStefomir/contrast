import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/tab.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the header of the board page
class BoardPageFilter extends ConsumerWidget {

  const BoardPageFilter({super.key});

  /// Render mobile layout
  Widget _renderMobileLayout(BuildContext context, WidgetRef ref) => ShadowWidget(
    blurRadius: 2,
    offset: const Offset(3, 0),
    child: Container(
      width: mobileMenuWidth,
      height: MediaQuery.of(context).size.height - mobileMenuWidth,
      color: Colors.white,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.0),
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const RotatedBox(
                quarterTurns: 3,
                child: StyledText(
                  text: 'C O N T R A S T',
                  color: Colors.black,
                  useShadow: false,
                ),
              ),
              MenuButton(
                  widgetKey: const Key('qr_code'),
                  iconPath: 'qr_code.svg',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: false,
                  size: mobileMenuIconSize,
                  onClick: () => ref.read(overlayVisibilityProvider(const Key('qr_code')).notifier).setOverlayVisibility(true)
              ).translateOnPhotoHover,
              const Spacer(),
              MenuButton(
                  widgetKey: const Key('all'),
                  iconPath: 'all.svg',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'all',
                  size: mobileMenuIconSize,
                  onClick: () => ref.read(boardHeaderTabProvider.notifier).switchTab('all')
              ).translateOnPhotoHover,
              MenuButton(
                  widgetKey: const Key('landscape'),
                  iconPath: 'landscape.svg',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'landscape',
                  size: mobileMenuIconSize,
                  onClick: () => ref.read(boardHeaderTabProvider.notifier).switchTab('landscape')
              ).translateOnPhotoHover,
              MenuButton(
                  widgetKey: const Key('portraits'),
                  iconPath: 'portraits.svg',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'portraits',
                  size: mobileMenuIconSize,
                  onClick: () => ref.read(boardHeaderTabProvider.notifier).switchTab('portraits')
              ).translateOnPhotoHover,
              MenuButton(
                  widgetKey: const Key('street'),
                  iconPath: 'street.svg',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'street',
                  size: mobileMenuIconSize,
                  onClick: () => ref.read(boardHeaderTabProvider.notifier).switchTab('street')
              ).translateOnPhotoHover,
              MenuButton(
                  widgetKey: const Key('other'),
                  iconPath: 'dog.svg',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'other',
                  size: mobileMenuIconSize,
                  onClick: () => ref.read(boardHeaderTabProvider.notifier).switchTab('other')
              ).translateOnPhotoHover,
            ],
          ),
        )
      ]),
    ),
  );

  /// Render desktop layout
  Widget _renderDesktopLayout(WidgetRef ref) => ShadowWidget(
    offset: const Offset(0, 2),
    blurRadius: 2,
    child: Container(
      color: Colors.white,
      height: desktopTopPadding,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                    widgetKey: const Key('all'),
                    text: 'all',
                    onClick: (String tab) => ref.read(boardHeaderTabProvider.notifier).switchTab(tab),
                    isSelected: ref.watch(boardHeaderTabProvider) == 'all'
                ).translateOnPhotoHover,
                const Spacer(),
                ContrastTab(
                    widgetKey: const Key('landscape'),
                    text: 'landscape',
                    onClick: (String tab) => ref.read(boardHeaderTabProvider.notifier).switchTab(tab),
                    isSelected: ref.read(boardHeaderTabProvider) == 'landscape'
                ).translateOnPhotoHover,
                const Spacer(),
                ContrastTab(
                    widgetKey: const Key('portraits'),
                    text: 'portraits',
                    onClick: (String tab) => ref.read(boardHeaderTabProvider.notifier).switchTab(tab),
                    isSelected: ref.read(boardHeaderTabProvider) == 'portraits'
                ).translateOnPhotoHover,
                const Spacer(),
                ContrastTab(
                    widgetKey: const Key('street'),
                    text: 'street',
                    onClick: (String tab) => ref.read(boardHeaderTabProvider.notifier).switchTab(tab),
                    isSelected: ref.read(boardHeaderTabProvider) == 'street'
                ).translateOnPhotoHover,
                const Spacer(),
                ContrastTab(
                    widgetKey: const Key('other'),
                    text: 'other',
                    onClick: (String tab) => ref.read(boardHeaderTabProvider.notifier).switchTab(tab),
                    isSelected: ref.read(boardHeaderTabProvider) == 'other'
                ).translateOnPhotoHover,
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) => useMobileLayout(context)
      ? _renderMobileLayout(context, ref)
      : _renderDesktopLayout(ref);
}
