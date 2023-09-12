import 'package:contrast/common/widgets/blur.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import "package:universal_html/html.dart" as html;
import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/image_meta_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/footer.dart';
import 'package:contrast/modules/board/header.dart';
import 'package:contrast/modules/board/overlay/delete/delete.dart';
import 'package:contrast/modules/board/overlay/delete/provider.dart';
import 'package:contrast/modules/board/overlay/qr_code/qr_code.dart';
import 'package:contrast/modules/board/photograph/overlay/provider.dart';
import 'package:contrast/modules/board/photograph/overlay/upload.dart';
import 'package:contrast/modules/board/photograph/page.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/board/video/overlay/provider.dart';
import 'package:contrast/modules/board/video/overlay/upload.dart';
import 'package:contrast/modules/board/video/page.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/device.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const double boardPadding = 65;

class BoardPage extends StatefulHookConsumerWidget {
  /// Firebase plugins
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  const BoardPage({required this.analytics, required this.observer, super.key});

  @override
  ConsumerState createState() => BoardPageState();
}

class BoardPageState extends ConsumerState<BoardPage> {

  @override
  void initState() {
    // Send analytics when the widget is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.analytics.logAppOpen();
      widget.analytics.logEvent(
          name: 'board_page',
          parameters: <String, dynamic>{
            'layout': useMobileLayout(context) ? 'mobile' : 'desktop'
          });
    });
    html.window.onPopState.listen((event) => _onAction(ref, null));
    super.initState();
  }


  @override
  void dispose() {
    html.window.onPopState.drain();
    super.dispose();
  }

  /// What happens when the user performs an action
  void _onAction(WidgetRef ref, Function? action) {
    ref.read(overlayVisibilityProvider(const Key('qr_code')).notifier).setOverlayVisibility(null);
    ref.read(overlayVisibilityProvider(const Key('delete_image')).notifier).setOverlayVisibility(null);
    ref.read(overlayVisibilityProvider(const Key('delete_video')).notifier).setOverlayVisibility(null);
    ref.read(overlayVisibilityProvider(const Key('upload_image')).notifier).setOverlayVisibility(null);
    ref.read(fileProvider.notifier).setData(null, null, null, null);
    ref.read(overlayVisibilityProvider(const Key('edit_image')).notifier).setOverlayVisibility(null);
    ref.read(overlayVisibilityProvider(const Key('upload_video')).notifier).setOverlayVisibility(null);
    ref.read(overlayVisibilityProvider(const Key('edit_video')).notifier).setOverlayVisibility(null);
    if(action != null) {
      action();
    }
  }

  /// Handles the escape key of the keyboard
  void _handleKeyEvent(RawKeyEvent event) {
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        _onAction(ref, null);
    }
  }

  /// Renders the floating action button
  Widget _buildFloatingActionButtons(BuildContext context, WidgetRef ref) => Padding(
    padding: EdgeInsets.all(useMobileLayout(context) ? 95 : 37.0),
    child: SpeedDial(
        animatedIcon: AnimatedIcons.add_event,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
        direction: SpeedDialDirection.up,
        animationDuration: const Duration(milliseconds: 500),
        elevation: 1,
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
                      text: FlutterI18n.translate(context, 'Upload Video'),
                      padding: 5,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              child: const Icon(Icons.video_call),
              shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 1,
              onTap: () => _onAction(ref, () => ref.read(overlayVisibilityProvider(const Key('upload_video')).notifier).setOverlayVisibility(true))
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
                      text: FlutterI18n.translate(context, 'Upload Photograph'),
                      padding: 5,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              child: const Icon(Icons.photo_filter_sharp),
              shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 1,
              onTap: () => _onAction(ref, () => ref.read(overlayVisibilityProvider(const Key('upload_image')).notifier).setOverlayVisibility(true))
          )
        ]
    ),
  ).translateOnPhotoHover;

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
  Widget build(BuildContext context) {
    final bool? shouldShowQrCodeDialog = ref.watch(overlayVisibilityProvider(const Key('qr_code')));
    final bool? shouldShowDeletePhotographDialog = ref.watch(overlayVisibilityProvider(const Key('delete_image')));
    final bool? shouldShowDeleteVideoDialog = ref.watch(overlayVisibilityProvider(const Key('delete_video')));
    final bool? shouldShowUploadPhotographDialog = ref.watch(overlayVisibilityProvider(const Key('upload_image')));
    final bool? shouldShowEditPhotographDialog = ref.watch(overlayVisibilityProvider(const Key('edit_image')));
    final bool? shouldShowUploadVideoDialog = ref.watch(overlayVisibilityProvider(const Key('upload_video')));
    final bool? shouldShowEditVideoDialog = ref.watch(overlayVisibilityProvider(const Key('edit_video')));
    double titlePadding = 0;
    /// In mobile view we need to calculate a padding so that the title
    /// can be in the center of the screen because of the left drawer
    /// that the mobile view has. If its a desktop view we do nothing.
      useValueChanged(ref.watch(boardHeaderTabProvider), (_, __) async {
        if (useMobileLayout(context)) {
          if (ref.watch(boardFooterTabProvider) == 'photos') {
            titlePadding = boardPadding;
          }
        }
      });

    return WillPopScope(
      onWillPop: () async {
        _onAction(ref, null);

        return false;
      },
      child: BackgroundPage(
          child: RawKeyboardListener(
            focusNode: useFocusNode(),
            onKey: _handleKeyEvent,
            child: Stack(
                children: [
                  Align(
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
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: titlePadding),
                            child: StyledText(
                              text: FlutterI18n.translate(
                                  context,
                                  (useMobileLayout(context) && ref.read(boardFooterTabProvider) == 'photos')
                                      ? ref.read(boardHeaderTabProvider)
                                      : 'CONTRAST'
                              ),
                              color: Colors.black,
                              useShadow: false,
                              weight: FontWeight.bold,
                              letterSpacing: 10,
                              fontSize: useMobileLayout(context) ? 30 : 60,
                            ),
                          )
                      )
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: !useMobileLayout(context)
                            ? EdgeInsets.only(top: ref.read<String>(boardFooterTabProvider) == 'photos' ? boardPadding : 0, bottom: boardPadding)
                            : EdgeInsets.only(top: 0.2, left: ref.read<String>(boardFooterTabProvider) == 'photos' ? boardPadding : 0, bottom: boardPadding),
                        child: ref.read(boardFooterTabProvider) == 'photos'
                            ? SlideTransitionAnimation(
                            getStart: () => _calculateBoardStartAnimation(ref),
                            getEnd: () => const Offset(0, 0),
                            whenTo: (controller) {
                              final String currentTab = ref.watch(
                                  boardFooterTabProvider);
                              final String currentFilter = ref.watch(
                                  boardHeaderTabProvider);
                              useValueChanged(currentTab, (_, __) async {
                                controller.reset();
                                controller.forward();
                              });
                              useValueChanged(currentFilter, (_, __) async {
                                controller.reset();
                                controller.forward();
                              });
                            },
                            duration: const Duration(milliseconds: 800),
                            child: PhotographBoardPage(onUserAction: _onAction))
                            : SlideTransitionAnimation(
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
                            duration: const Duration(milliseconds: 800),
                            child: VideoBoardPage(onUserAction: _onAction)
                        ),
                      )
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: SlideTransitionAnimation(
                          getStart: () => const Offset(0.0, 1),
                          getEnd: () => Offset.zero,
                          duration: const Duration(milliseconds: 1200),
                          child: BoardPageFooter(onUserAction: _onAction)
                      )
                  ),
                  Align(
                      alignment: useMobileLayout(context)
                          ? Alignment.topLeft
                          : Alignment.topCenter,
                      child: SlideTransitionAnimation(
                          duration: const Duration(milliseconds: 1200),
                          getStart: () =>
                          ref.watch(boardFooterTabProvider) == 'photos'
                              ? const Offset(0, -10)
                              : Offset(0.0, ref.watch(boardFooterTabProvider) == 'videos' ? 0 : -10),
                          getEnd: () =>
                          ref.watch(boardFooterTabProvider) == 'photos'
                              ? Offset.zero
                              : Offset(0, ref.watch(boardFooterTabProvider) == 'videos' ? -10 : 10),
                          whenTo: (controller) {
                            final String currentTab = ref.watch(boardFooterTabProvider);
                            useValueChanged(currentTab, (_, __) async {
                              controller.reset();
                              controller.forward();
                            });
                          },
                          child: BoardPageFilter(onUserAction: _onAction)
                      )
                  ),
                  Visibility(
                      visible: Session().isLoggedIn(),
                      child: Align(
                          alignment: useMobileLayout(context)
                              ? Alignment.bottomCenter
                              : Alignment.bottomRight,
                          child: _buildFloatingActionButtons(context, ref)
                      )
                  ),
                  Visibility(
                      visible: (shouldShowQrCodeDialog != null && shouldShowQrCodeDialog) ||
                          (shouldShowDeletePhotographDialog != null && shouldShowDeletePhotographDialog) ||
                          (shouldShowDeleteVideoDialog != null && shouldShowDeleteVideoDialog) ||
                          (shouldShowUploadPhotographDialog != null && shouldShowUploadPhotographDialog) ||
                          (shouldShowEditPhotographDialog != null && shouldShowEditPhotographDialog) ||
                          (shouldShowUploadVideoDialog != null && shouldShowUploadVideoDialog) ||
                          (shouldShowEditVideoDialog != null && shouldShowEditVideoDialog),
                      child: const Blurrable(strength: 10),
                  ),
                  shouldShowDeletePhotographDialog != null ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransitionAnimation(
                      duration: const Duration(milliseconds: 1000),
                      getStart: () => shouldShowDeletePhotographDialog ? const Offset(0, 1) : const Offset(0, 0),
                      getEnd: () => shouldShowDeletePhotographDialog ? const Offset(0, 0) : const Offset(0, 10),
                      whenTo: (controller) {
                        useValueChanged(shouldShowDeletePhotographDialog, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                      },
                      onCompleted: () {
                        if(!shouldShowDeletePhotographDialog) {
                          ref.read(deleteImageProvider.notifier).setDeleteImage(null);
                        }
                      },
                      child: DeleteDialog<ImageData>(
                        data: ref.read(deleteImageProvider),
                        onSubmit: (image) {
                          if (image != null) {
                            ref.read(photographServiceFetchProvider.notifier).removeItem(
                                ref.read(photographServiceFetchProvider).firstWhere((element) => element.image.id == image.id)
                            );
                            ref.read(deleteImageProvider.notifier).setDeleteImage(null);
                            ref.read(overlayVisibilityProvider(const Key('delete_image')).notifier).setOverlayVisibility(false);
                            showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Photograph was successfully deleted'));
                          }
                        },
                      ),
                    ),
                  ) : Container(),
                  shouldShowDeleteVideoDialog != null ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransitionAnimation(
                      duration: const Duration(milliseconds: 1000),
                      getStart: () => shouldShowDeleteVideoDialog ? const Offset(0, 1) : const Offset(0, 0),
                      getEnd: () => shouldShowDeleteVideoDialog ? const Offset(0, 0) : const Offset(0, 10),
                      whenTo: (controller) {
                        useValueChanged(shouldShowDeleteVideoDialog, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                      },
                      onCompleted: () {
                        if(!shouldShowDeleteVideoDialog) {
                          ref.read(deleteImageProvider.notifier).setDeleteImage(null);
                        }
                      },
                      child: DeleteDialog<VideoData>(
                        data: ref.read(deleteVideoProvider),
                        onSubmit: (video) {
                          if (video != null) {
                            ref.read(videoServiceFetchProvider.notifier).removeItem(
                                ref.read(videoServiceFetchProvider).firstWhere((element) => element.id == video.id)
                            );
                            ref.read(deleteVideoProvider.notifier).setDeleteVideo(null);
                            ref.read(overlayVisibilityProvider(const Key('delete_video')).notifier).setOverlayVisibility(false);
                            showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Video was successfully deleted'));
                          }
                        },
                      ),
                    ),
                  ) : Container(),
                  shouldShowEditPhotographDialog != null ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransitionAnimation(
                      duration: const Duration(milliseconds: 1000),
                      getStart: () => shouldShowEditPhotographDialog ? const Offset(0, 1) : const Offset(0, 0),
                      getEnd: () => shouldShowEditPhotographDialog ? const Offset(0, 0) : const Offset(0, 10),
                      whenTo: (controller) {
                        useValueChanged(shouldShowEditPhotographDialog, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                      },
                      onCompleted: () {
                        if(!shouldShowEditPhotographDialog) {
                          ref.read(photographEditProvider.notifier).setEditImage(null);
                        }
                      },
                      child: UploadImageDialog(
                        data: ref.read(photographEditProvider),
                        onSubmit: (image) {
                          final ImageMetaData meta = ref.read(photographServiceFetchProvider).firstWhere((element) => element.image.id == element.image.id).metadata;
                          ref.read(photographServiceFetchProvider.notifier).removeItem(
                              ref.read(photographServiceFetchProvider).firstWhere((element) => element.image.id == image.image.id)
                          );
                          ref.read(photographServiceFetchProvider.notifier).addItem(ImageWrapper(image: image.image, metadata: meta));
                          ref.read(photographEditProvider.notifier).setEditImage(null);
                          ref.read(overlayVisibilityProvider(const Key('edit_image')).notifier).setOverlayVisibility(false);
                          showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Photograph was successfully edited'));
                        },
                      ),
                    ),
                  ) : Container(),
                  shouldShowUploadPhotographDialog != null ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransitionAnimation(
                      duration: const Duration(milliseconds: 1000),
                      getStart: () => shouldShowUploadPhotographDialog ? const Offset(0, 1) : const Offset(0, 0),
                      getEnd: () => shouldShowUploadPhotographDialog ? const Offset(0, 0) : const Offset(0, 10),
                      whenTo: (controller) {
                        useValueChanged(shouldShowUploadPhotographDialog, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                      },
                      child: UploadImageDialog(
                        onSubmit: (image) {
                          ref.read(photographServiceFetchProvider.notifier).addItem(image);
                          ref.read(overlayVisibilityProvider(const Key('upload_image')).notifier).setOverlayVisibility(false);
                          showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Photograph was successfully uploaded'));
                        },
                      ),
                    ),
                  ) : Container(),
                  shouldShowUploadVideoDialog != null ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransitionAnimation(
                      duration: const Duration(milliseconds: 1000),
                      getStart: () => shouldShowUploadVideoDialog ? const Offset(0, 1) : const Offset(0, 0),
                      getEnd: () => shouldShowUploadVideoDialog ? const Offset(0, 0) : const Offset(0, 10),
                      whenTo: (controller) {
                        useValueChanged(shouldShowUploadVideoDialog, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                      },
                      child: UploadVideoDialog(
                        onSubmit: (video) {
                          ref.read(videoServiceFetchProvider.notifier).addItem(video);
                          ref.read(overlayVisibilityProvider(const Key('upload_video')).notifier).setOverlayVisibility(false);
                          showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Video was successfully uploaded'));
                        },
                      ),
                    ),
                  ) : Container(),
                  shouldShowEditVideoDialog != null ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransitionAnimation(
                      duration: const Duration(milliseconds: 1000),
                      getStart: () => shouldShowEditVideoDialog ? const Offset(0, 1) : const Offset(0, 0),
                      getEnd: () => shouldShowEditVideoDialog ? const Offset(0, 0) : const Offset(0, 10),
                      whenTo: (controller) {
                        useValueChanged(shouldShowEditVideoDialog, (_, __) async {
                          controller.reset();
                          controller.forward();
                        });
                      },
                      onCompleted: () {
                        if(!shouldShowEditVideoDialog) {
                          ref.read(videoEditProvider.notifier).setEditVideo(null);
                        }
                      },
                      child: UploadVideoDialog(
                        data: ref.read(videoEditProvider),
                        onSubmit: (video) {
                          ref.read(videoServiceFetchProvider.notifier).removeItem(
                              ref.read(videoServiceFetchProvider).firstWhere((element) => element.id == video.id)
                          );
                          ref.read(videoServiceFetchProvider.notifier).addItem(video);
                          ref.read(videoEditProvider.notifier).setEditVideo(null);
                          ref.read(overlayVisibilityProvider(const Key('edit_video')).notifier).setOverlayVisibility(false);
                          showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Video was successfully edited'));
                        },
                      ),
                    ),
                  ) : Container(),
                  shouldShowQrCodeDialog != null ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransitionAnimation(
                        duration: const Duration(milliseconds: 1000),
                        getStart: () => shouldShowQrCodeDialog ? const Offset(0, 1) : const Offset(0, 0),
                        getEnd: () => shouldShowQrCodeDialog ? const Offset(0, 0) : const Offset(0, 10),
                        whenTo: (controller) {
                          useValueChanged(shouldShowQrCodeDialog, (_, __) async {
                            controller.reset();
                            controller.forward();
                          });
                        },
                        child: const QrCodeDialog()
                    ),
                  ) : Container()
                ]
            ),
          )
      ),
    );
  }
}
