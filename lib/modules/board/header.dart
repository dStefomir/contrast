import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/tab.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the header of the board page
class BoardPageFilter extends ConsumerWidget {

  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const BoardPageFilter({super.key, required this.onUserAction});

  /// Render mobile layout
  Widget _renderMobileLayout(BuildContext context, WidgetRef ref) => ShadowWidget(
    key: const Key('HeaderMobileLayoutShadowWidget'),
    blurRadius: 2,
    offset: const Offset(3, 0),
    child: Container(
      key: const Key('HeaderMobileLayoutContainer'),
      width: boardPadding,
      height: MediaQuery.of(context).size.height - boardPadding - (kIsWeb ? 0 : 60),
      color: Colors.white,
      child: Stack(
          key: const Key('HeaderMobileLayoutStack'),
          children: [
            Container(
              key: const Key('HeaderMobileLayoutStackContainer'),
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
            Align(key: const Key('HeaderMobileLayoutStackAlignColumn'),
              alignment: Alignment.topLeft,
              child: Column(
                key: const Key('HeaderMobileLayoutStackColumn'),
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      key: const Key('HeaderMobileLayoutStackSignatureContainer'),
                      color: Colors.transparent,
                      height: 70,
                      padding: const EdgeInsets.all(5),
                      child: const IconRenderer(
                          key: Key('HeaderMobileLayoutStackSignatureSvg'),
                          asset: 'signature.svg',
                          color: Colors.black,
                          fit: BoxFit.scaleDown
                      )
                  ),
                  const Spacer(key: Key('HeaderMobileLayoutStackAllSpacer')),
                  MenuButton(
                      widgetKey: const Key('all'),
                      iconPath: 'all.svg',
                      tooltip: FlutterI18n.translate(context, 'All'),
                      disabled: ref.watch(boardFooterTabProvider) == 'videos',
                      selected: ref.watch(boardHeaderTabProvider) == 'all',
                      size: boardPadding,
                      onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('all'))
                  ).translateOnPhotoHover,
                  MenuButton(
                      widgetKey: const Key('landscape'),
                      iconPath: 'landscape.svg',
                      tooltip: FlutterI18n.translate(context, 'Landscape'),
                      disabled: ref.watch(boardFooterTabProvider) == 'videos',
                      selected: ref.watch(boardHeaderTabProvider) == 'landscape',
                      size: boardPadding,
                      onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('landscape'))
                  ).translateOnPhotoHover,
                  MenuButton(
                      widgetKey: const Key('portraits'),
                      iconPath: 'portraits.svg',
                      tooltip: FlutterI18n.translate(context, 'Portraits'),
                      disabled: ref.watch(boardFooterTabProvider) == 'videos',
                      selected: ref.watch(boardHeaderTabProvider) == 'portraits',
                      size: boardPadding,
                      onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('portraits'))
                  ).translateOnPhotoHover,
                  MenuButton(
                      widgetKey: const Key('street'),
                      iconPath: 'street.svg',
                      tooltip: FlutterI18n.translate(context, 'Street'),
                      disabled: ref.watch(boardFooterTabProvider) == 'videos',
                      selected: ref.watch(boardHeaderTabProvider) == 'street',
                      size: boardPadding,
                      onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('street'))
                  ).translateOnPhotoHover,
                  MenuButton(
                      widgetKey: const Key('other'),
                      iconPath: 'dog.svg',
                      tooltip: FlutterI18n.translate(context, 'Other'),
                      disabled: ref.watch(boardFooterTabProvider) == 'videos',
                      selected: ref.watch(boardHeaderTabProvider) == 'other',
                      size: boardPadding,
                      onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('other'))
                  ).translateOnPhotoHover,
                ],
              ),
            )
          ]
      ),
    ),
  );

  /// Render desktop layout
  Widget _renderDesktopLayout(BuildContext context, WidgetRef ref) => ShadowWidget(
    key: const Key('HeaderDesktopLayoutShadowWidget'),
    offset: const Offset(0, 2),
    blurRadius: 2,
    child: Container(
      key: const Key('HeaderDesktopLayoutContainer'),
      color: Colors.white,
      height: boardPadding,
      child: Stack(
        key: const Key('HeaderDesktopLayoutStack'),
        children: [
          IconRenderer(
              key: const Key('HeaderDesktopLayoutStackBackgroundSvg'),
              asset: 'background.svg',
              fit: BoxFit.fitWidth,
              width: double.infinity,
              color: Colors.black.withOpacity(0.05)
          ),
          Align(
            key: const Key('HeaderDesktopLayoutStackAlign'),
            alignment: Alignment.center,
            child: Row(
              key: const Key('HeaderDesktopLayoutRow'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(key: Key('HeaderDesktopLayoutAllSpacer')),
                ContrastTab(
                    widgetKey: const Key('all'),
                    tabKey: 'all',
                    text: FlutterI18n.translate(context, 'all'),
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.watch(boardHeaderTabProvider) == 'all'
                ).translateOnPhotoHover,
                const Spacer(key: Key('HeaderDesktopLayoutLandscapeSpacer')),
                ContrastTab(
                    widgetKey: const Key('landscape'),
                    tabKey: 'landscape',
                    text: FlutterI18n.translate(context, 'landscape'),
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.read(boardHeaderTabProvider) == 'landscape'
                ).translateOnPhotoHover,
                const Spacer(key: Key('HeaderDesktopLayoutPortraitsSpacer')),
                ContrastTab(
                    widgetKey: const Key('portraits'),
                    tabKey: 'portraits',
                    text: FlutterI18n.translate(context, 'portraits'),
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.read(boardHeaderTabProvider) == 'portraits'
                ).translateOnPhotoHover,
                const Spacer(key: Key('HeaderDesktopLayoutStreetSpacer')),
                ContrastTab(
                    widgetKey: const Key('street'),
                    tabKey: 'street',
                    text: FlutterI18n.translate(context, 'street'),
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.read(boardHeaderTabProvider) == 'street'
                ).translateOnPhotoHover,
                const Spacer(key: Key('HeaderDesktopLayoutOtherSpacer')),
                ContrastTab(
                    widgetKey: const Key('other'),
                    tabKey: 'other',
                    text: FlutterI18n.translate(context, 'other'),
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.read(boardHeaderTabProvider) == 'other'
                ).translateOnPhotoHover,
                const Spacer(key: Key('HeaderDesktopLayoutEndSpacer')),
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
      : _renderDesktopLayout(context, ref);
}
