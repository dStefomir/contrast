import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/tab.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/device.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the header of the board page
class BoardPageFilter extends ConsumerWidget {

  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const BoardPageFilter({super.key, required this.onUserAction});

  /// Render mobile layout
  Widget _renderMobileLayout(BuildContext context, WidgetRef ref) => LayoutBuilder(builder: (context, constraints) =>
      ShadowWidget(
        blurRadius: 3,
        offset: const Offset(0.5, -5),
        shadowColor: Colors.black,
        child: Container(
          width: boardPadding,
          height: constraints.maxHeight - boardPadding - 0.2,
          color: Colors.white,
          child: Stack(
              children: [
            Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RotatedBox(
                        quarterTurns: 3,
                        child: StyledText(
                            text: 'CONTRASTUS'.tr(),
                            padding: 5,
                            fontSize: 15,
                            weight: FontWeight.bold,
                            letterSpacing: 15,
                            useShadow: true,
                            color: Colors.white.withValues(alpha: 0.6)
                        ),
                      ),
                      const Spacer(),
                      MenuButton(
                          widgetKey: const Key('all'),
                          iconPath: 'all.svg',
                          tooltip: 'All'.tr(),
                          disabled: ref.watch(boardFooterTabProvider) == 'videos',
                          selected: ref.watch(boardHeaderTabProvider) == 'all',
                          size: boardPadding,
                          onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('all'))
                      ).translateOnPhotoHover,
                      MenuButton(
                          widgetKey: const Key('landscape'),
                          iconPath: 'landscape.svg',
                          tooltip: 'Landscape'.tr(),
                          disabled: ref.watch(boardFooterTabProvider) == 'videos',
                          selected: ref.watch(boardHeaderTabProvider) == 'landscape',
                          size: boardPadding,
                          onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('landscape'))
                      ).translateOnPhotoHover,
                      MenuButton(
                          widgetKey: const Key('portraits'),
                          iconPath: 'portraits.svg',
                          tooltip: 'Portraits'.tr(),
                          disabled: ref.watch(boardFooterTabProvider) == 'videos',
                          selected: ref.watch(boardHeaderTabProvider) == 'portraits',
                          size: boardPadding,
                          onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('portraits'))
                      ).translateOnPhotoHover,
                      MenuButton(
                          widgetKey: const Key('street'),
                          iconPath: 'street.svg',
                          tooltip: 'Street'.tr(),
                          disabled: ref.watch(boardFooterTabProvider) == 'videos',
                          selected: ref.watch(boardHeaderTabProvider) == 'street',
                          size: boardPadding,
                          onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('street'))
                      ).translateOnPhotoHover,
                      MenuButton(
                          widgetKey: const Key('other'),
                          iconPath: 'dog.svg',
                          tooltip: 'Other'.tr(),
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
      )
  );

  /// Render desktop layout
  Widget _renderDesktopLayout(BuildContext context, WidgetRef ref) => ShadowWidget(
    offset: const Offset(0, 2),
    blurRadius: 2,
    child: Container(
      color: Colors.white,
      height: boardPadding,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: boardPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  ContrastTab(
                      widgetKey: const Key('all'),
                      tabKey: 'all',
                      text: 'all'.tr(),
                      onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                      isSelected: ref.watch(boardHeaderTabProvider) == 'all'
                  ).translateOnPhotoHover,
                  const Spacer(),
                  ContrastTab(
                      widgetKey: const Key('landscape'),
                      tabKey: 'landscape',
                      text: 'landscape'.tr(),
                      onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                      isSelected: ref.read(boardHeaderTabProvider) == 'landscape'
                  ).translateOnPhotoHover,
                  const Spacer(),
                  ContrastTab(
                      widgetKey: const Key('portraits'),
                      tabKey: 'portraits',
                      text: 'portraits'.tr(),
                      onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                      isSelected: ref.read(boardHeaderTabProvider) == 'portraits'
                  ).translateOnPhotoHover,
                  const Spacer(),
                  ContrastTab(
                      widgetKey: const Key('street'),
                      tabKey: 'street',
                      text: 'street'.tr(),
                      onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                      isSelected: ref.read(boardHeaderTabProvider) == 'street'
                  ).translateOnPhotoHover,
                  const Spacer(),
                  ContrastTab(
                      widgetKey: const Key('other'),
                      tabKey: 'other',
                      text: 'other'.tr(),
                      onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                      isSelected: ref.read(boardHeaderTabProvider) == 'other'
                  ).translateOnPhotoHover,
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) => useMobileLayoutOriented(context)
      ? _renderMobileLayout(context, ref)
      : _renderDesktopLayout(context, ref);
}
