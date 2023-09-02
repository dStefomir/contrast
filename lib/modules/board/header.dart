import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/tab.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the header of the board page
class BoardPageFilter extends ConsumerWidget {

  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const BoardPageFilter({super.key, required this.onUserAction});

  /// Render mobile layout
  Widget _renderMobileLayout(BuildContext context, WidgetRef ref) => ShadowWidget(
    blurRadius: 2,
    offset: const Offset(3, 0),
    child: Container(
      width: boardPadding,
      height: MediaQuery.of(context).size.height - boardPadding,
      color: Colors.white,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.15),
                Colors.black.withOpacity(0.0),
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
                  quarterTurns: 5,
                child: StyledText(text: 'Contrast',),
              ),
              const Spacer(),
              MenuButton(
                  widgetKey: const Key('all'),
                  iconPath: 'all.svg',
                  tooltip: 'All',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'all',
                  size: boardPadding,
                  onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('all'))
              ).translateOnPhotoHover,
              MenuButton(
                  widgetKey: const Key('landscape'),
                  iconPath: 'landscape.svg',
                  tooltip: 'Landscape',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'landscape',
                  size: boardPadding,
                  onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('landscape'))
              ).translateOnPhotoHover,
              MenuButton(
                  widgetKey: const Key('portraits'),
                  iconPath: 'portraits.svg',
                  tooltip: 'Portraits',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'portraits',
                  size: boardPadding,
                  onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('portraits'))
              ).translateOnPhotoHover,
              MenuButton(
                  widgetKey: const Key('street'),
                  iconPath: 'street.svg',
                  tooltip: 'Street',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'street',
                  size: boardPadding,
                  onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('street'))
              ).translateOnPhotoHover,
              MenuButton(
                  widgetKey: const Key('other'),
                  iconPath: 'dog.svg',
                  tooltip: 'Other',
                  disabled: ref.watch(boardFooterTabProvider) == 'videos',
                  selected: ref.watch(boardHeaderTabProvider) == 'other',
                  size: boardPadding,
                  onClick: () => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab('other'))
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
      height: boardPadding,
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
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.watch(boardHeaderTabProvider) == 'all'
                ).translateOnPhotoHover,
                const Spacer(),
                ContrastTab(
                    widgetKey: const Key('landscape'),
                    text: 'landscape',
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.read(boardHeaderTabProvider) == 'landscape'
                ).translateOnPhotoHover,
                const Spacer(),
                ContrastTab(
                    widgetKey: const Key('portraits'),
                    text: 'portraits',
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.read(boardHeaderTabProvider) == 'portraits'
                ).translateOnPhotoHover,
                const Spacer(),
                ContrastTab(
                    widgetKey: const Key('street'),
                    text: 'street',
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
                    isSelected: ref.read(boardHeaderTabProvider) == 'street'
                ).translateOnPhotoHover,
                const Spacer(),
                ContrastTab(
                    widgetKey: const Key('other'),
                    text: 'other',
                    onClick: (String tab) => onUserAction(ref, () => ref.read(boardHeaderTabProvider.notifier).switchTab(tab)),
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
