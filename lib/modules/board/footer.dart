import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shader/widget.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/shape.dart';
import 'package:contrast/common/widgets/tab.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/common/widgets/tooltip.dart';
import 'package:contrast/modules/board/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders the footer of the board page
class BoardPageFooter extends HookConsumerWidget {

  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const BoardPageFooter({super.key, required this.onUserAction});

  /// Renders the mobile layout
  Widget _renderMobileLayout(BuildContext context, WidgetRef ref, String currentTab) {
    final photographTab = IconRenderer(
      asset: 'photo.svg',
      color: currentTab == 'photos' ? Colors.white: Colors.black,
      height: 50,
    ).translateOnPhotoHover;
    final videoTab = IconRenderer(
        asset: 'video.svg',
        color: currentTab == 'videos' ? Colors.white: Colors.black,
        height: 50
    ).translateOnPhotoHover;

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: ShadowWidget(
            offset: const Offset(0, -2),
            blurRadius: 2,
            child: Container(
              height: boardPadding,
              decoration: BoxDecoration(
                color: Colors.transparent,
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
                      text: translate('Photographs'),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ref.read(boardFooterTabProvider.notifier).switchTab('photos'),
                          child: Container(
                              height: boardPadding,
                              padding: EdgeInsets.all(currentTab == 'photos' ? 11.0 : 13.0),
                              decoration: BoxDecoration(
                                color: currentTab == 'photos' ? Colors.black: Colors.white,
                              ),
                              child: currentTab == 'photos' ? Shimmer.fromColors(
                                  baseColor: Colors.grey.shade400,
                                  highlightColor: Colors.white,
                                  child: photographTab
                              ) : photographTab
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 120),
                  Expanded(
                    child: StyledTooltip(
                      text: translate('Videos'),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref.read(boardHeaderTabProvider.notifier).switchTab('all');
                            ref.read(boardFooterTabProvider.notifier).switchTab('videos');
                          },
                          child: Container(
                            height: boardPadding,
                            padding: EdgeInsets.all(currentTab == 'videos' ? 11.0: 13.0),
                            decoration: BoxDecoration(
                              color: currentTab == 'videos' ? Colors.black: Colors.white,
                            ),
                            child: currentTab == 'videos' ? Shimmer.fromColors(
                                baseColor: Colors.grey.shade400,
                                highlightColor: Colors.white,
                                child: videoTab
                            ) : videoTab
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: _HomeSection(onUserAction: onUserAction).translateOnPhotoHover
        ),
      ],
    );
  }

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
              alignment: Alignment.center,
              children: [
                IconRenderer(
                    asset: 'background_landscape.svg',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.1)
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0),
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: BlurryContainer(
                    height: boardPadding,
                    blur: 1.4,
                    elevation: 0,
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        ContrastTab(
                            widgetKey: const Key('photos'),
                            tabKey: 'photos',
                            text: translate('photos'),
                            onClick: (String tab) => ref.read(boardFooterTabProvider.notifier).switchTab(tab),
                            isSelected: currentTab == 'photos'
                        ).translateOnPhotoHover,
                        const Spacer(),
                        const SizedBox(width: 160),
                        const Spacer(),
                        ContrastTab(
                            widgetKey: const Key('videos'),
                            tabKey: 'videos',
                            text: translate('videos'),
                            onClick: (String tab) {
                              ref.read(boardHeaderTabProvider.notifier).switchTab('all');
                              ref.read(boardFooterTabProvider.notifier).switchTab(tab);
                              },
                            isSelected: currentTab == 'videos'
                        ).translateOnPhotoHover,
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: _HomeSection(onUserAction: onUserAction).translateOnPhotoHover,
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentTab = ref.watch(boardFooterTabProvider);

    return useMobileLayoutOriented(context)
        ? _renderMobileLayout(context, ref, currentTab)
        : _renderDesktopLayout(context, ref, currentTab);
  }
}

/// Renders the home section of the footer
class _HomeSection extends HookConsumerWidget {

  /// What happens when the user performs an action
  final Function(WidgetRef ref, Function? action) onUserAction;

  const _HomeSection({required this.onUserAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) => CustomPaint(
    painter: HouseShadowPainter(),
    child: ClipPath(
      clipper: HouseShape(),
      child: SizedBox(
          width: 120,
          child: ShaderWidget(
              asset: 'background.glsl',
              child: StyledTooltip(
                text: translate('Menu'),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SpeedDial(
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
                            foregroundColor: Colors.black,
                            labelBackgroundColor: Colors.white,
                            labelWidget: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ShadowWidget(
                                offset: const Offset(0, 0),
                                blurRadius: 1,
                                shadowSize: 0.1,
                                child: Container(
                                  color: Colors.white,
                                  child: StyledText(
                                    text: translate('About me'),
                                    padding: 5,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            child: const IconRenderer(
                              asset: 'about.svg',
                              color: Colors.black,
                              height: 20,
                            ),
                            shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                            elevation: 1,
                            onTap: () => Modular.to.pushNamed('/about')
                        ),
                        SpeedDialChild(
                            foregroundColor: Colors.black,
                            labelBackgroundColor: Colors.white,
                            labelWidget: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ShadowWidget(
                                offset: const Offset(0, 0),
                                blurRadius: 1,
                                shadowSize: 0.1,
                                child: Container(
                                  color: Colors.white,
                                  child: StyledText(
                                    key: const Key('AboutMeSpeedDialShareText'),
                                    text: translate('Share'),
                                    padding: 5,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            child: const IconRenderer(
                              asset: 'share.svg',
                              color: Colors.black,
                              height: 20,
                            ),
                            shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                            elevation: 1,
                            onTap: () => onUserAction(
                                ref,
                                    () => ref.read(overlayVisibilityProvider(const Key('share')).notifier).setOverlayVisibility(true)
                            )
                        ),
                        SpeedDialChild(
                            foregroundColor: Colors.black,
                            labelBackgroundColor: Colors.white,
                            labelWidget: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ShadowWidget(
                                offset: const Offset(0, 0),
                                blurRadius: 1,
                                shadowSize: 0.1,
                                child: Container(
                                  color: Colors.white,
                                  child: StyledText(
                                    text: translate('Qr code'),
                                    padding: 5,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            child: const IconRenderer(
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
              )
          )
      ),
    ),
  );
}
