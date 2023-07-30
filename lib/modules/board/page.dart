import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/footer.dart';
import 'package:contrast/modules/board/header.dart';
import 'package:contrast/modules/board/photograph/overlay/upload.dart';
import 'package:contrast/modules/board/photograph/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/board/video/overlay/upload.dart';
import 'package:contrast/modules/board/video/page.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const double desktopTopPadding = 65;
const double desktopBottomPadding = 65;
const double mobileMenuWidth = 65;
const double mobileMenuIconSize = 65;

class BoardPage extends HookConsumerWidget {
  /// Constraints of the page
  final BoxConstraints constraints;

  const BoardPage({required this.constraints, super.key});

  /// Renders the floating action button
  Widget _buildFloatingActionButtons(BuildContext context, WidgetRef ref) => Padding(
    padding: EdgeInsets.all(useMobileLayout(context) ? 95 : 35.0),
    child: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
              foregroundColor: Colors.black,
              labelBackgroundColor: Colors.white,
              child: const Icon(Icons.video_call),
              label: "Upload Video",
              onTap: () async {
                if (Session().isLoggedIn()) {
                  showDialog(
                      context: context,
                      builder: (context) => UploadVideoDialog(constraints: constraints)
                  ).then((video) {
                    ref.read(videoServiceFetchProvider.notifier).addItem(video);
                    showSuccessTextOnSnackBar(context, "Video was successfully uploaded.");
                  });
                }
              }),
          SpeedDialChild(
              foregroundColor: Colors.black,
              labelBackgroundColor: Colors.white,
              child: const Icon(Icons.photo_filter_sharp),
              label: "Upload Photograph",
              onTap: () async {
                if (Session().isLoggedIn()) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => UploadImageDialog(constraints: constraints)
                  ).then((photograph) {
                    ref.read(photographServiceFetchProvider.notifier).addItem(photograph);
                    showSuccessTextOnSnackBar(context, "Photograph was successfully uploaded.");
                  });
                }
              })
        ]
    ),
  );

  /// Calculates the offset for the starting animation of the board animation
  Offset _calculateBoardStartAnimation(WidgetRef ref) {
    final String currentTab = ref.watch(boardFooterTabProvider);
    final String currentFilter = ref.watch(boardHeaderTabProvider);
    double dx = -3;
    double dy = 0;

    useValueChanged(currentFilter, (_, __) async {
      if(currentTab == 'photos') {
        dx = 0;
        dy = -3;
      }
    });
    useValueChanged(currentTab, (_, __) async {
      if(currentTab == 'photos') {
        dx = -3;
        dy = 0;
      } else {
        dx = 3;
        dy = 0;
      }
    });

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => BackgroundPage(
      child: Stack(
          children: [
            Visibility(
              visible: !useMobileLayout(context),
              child: Align(
                  alignment: Alignment.center,
                  child: FadeAnimation(
                      start: 1,
                      end: 0,
                      whenTo: (controller) {
                        final String currentTab = ref.watch(boardFooterTabProvider);
                        final String currentFilter = ref.watch(boardHeaderTabProvider);
                        useValueChanged(currentTab, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                        useValueChanged(currentFilter, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });},
                      child: StyledText(
                        text: 'C O N T R A S T',
                        color: Colors.black,
                        useShadow: false,
                        weight: FontWeight.bold,
                        fontSize: constraints.maxWidth / 40,
                      )
                  )
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: !useMobileLayout(context)
                      ? EdgeInsets.only(top: ref.read<String>(boardFooterTabProvider) == 'photos' ? desktopTopPadding : 0, bottom: desktopBottomPadding)
                      : EdgeInsets.only(top: 0.2, left: ref.read<String>(boardFooterTabProvider) == 'photos' ? mobileMenuWidth : 0, bottom: mobileMenuWidth),
                    child: ref.read(boardFooterTabProvider) == 'photos'
                        ? SlideTransitionAnimation(
                      getStart: () => _calculateBoardStartAnimation(ref),
                      getEnd: () => const Offset(0, 0),
                      whenTo: (controller) {
                        final String currentTab = ref.watch(boardFooterTabProvider);
                        final String currentFilter = ref.watch(boardHeaderTabProvider);
                        useValueChanged(currentTab, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                        useValueChanged(currentFilter, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                        },
                      controller: useAnimationController(duration: const Duration(milliseconds: 500)),
                      child: PhotographBoardPage(constraints: constraints,)
                    ) : SlideTransitionAnimation(
                        getStart: () => _calculateBoardStartAnimation(ref),
                        getEnd: () => const Offset(0, 0),
                        whenTo: (controller) {
                          final String currentTab = ref.watch(boardFooterTabProvider);
                          final String currentFilter = ref.watch(boardHeaderTabProvider);
                          useValueChanged(currentTab, (_, __) async {
                            controller.reset();
                            controller.forward();
                          });
                          useValueChanged(currentFilter, (_, __) async {
                            controller.reset();
                            controller.forward();
                          });
                          },
                        controller: useAnimationController(duration: const Duration(milliseconds: 500)),
                        child: VideoBoardPage(constraints: constraints,)
                    ),
                )
            ),
            Align(
                alignment: useMobileLayout(context)
                    ? Alignment.topLeft
                    : Alignment.topCenter,
                child: SlideTransitionAnimation(duration: const Duration(milliseconds: 1000),
                    getStart: () => ref.watch(boardFooterTabProvider) == 'photos' ? const Offset(0, -10) : Offset(0.0, ref.watch(boardFooterTabProvider) == 'videos' ? 0 : -10),
                    getEnd: () => ref.watch(boardFooterTabProvider) == 'photos' ? Offset.zero : Offset(0, ref.watch(boardFooterTabProvider) == 'videos' ? -10 : 10),
                    whenTo: (controller) {
                      final String currentTab = ref.watch(boardFooterTabProvider);
                      useValueChanged(currentTab, (_, __) async {
                        controller.reset();
                        controller.forward();
                      });},
                    controller: useAnimationController(duration: const Duration(milliseconds: 1200)),
                    child: BoardPageFilter(constraints: constraints,)
                )
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransitionAnimation(
                    getStart: () => const Offset(0.0, 1),
                    getEnd: () => Offset.zero,
                    controller: useAnimationController(duration: const Duration(milliseconds: 1200)),
                    child: const BoardPageFooter()
                )
            ),
            Visibility(
                visible: Session().isLoggedIn(),
                child: Align(
                    alignment: useMobileLayout(context) ? Alignment.bottomCenter : Alignment.bottomRight,
                    child: _buildFloatingActionButtons(context, ref)
                )
            ),
          ]
      )
  );
}
