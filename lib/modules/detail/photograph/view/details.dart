import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:contrast/common/widgets/blur.dart';
import 'package:contrast/common/widgets/photograph.dart';
import 'package:contrast/model/image_comments.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/overlay/comment.dart';
import 'package:contrast/modules/detail/overlay/provider.dart';
import 'package:contrast/modules/detail/overlay/service.dart';
import 'package:contrast/modules/detail/photograph/overlay/trip_planning.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:loading_indicator/loading_indicator.dart';
import "package:universal_html/html.dart" as html;
import 'package:contrast/common/widgets/icon.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/map/map.dart';
import 'package:contrast/common/widgets/map/provider.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/detail/photograph/provider.dart';
import 'package:contrast/modules/detail/photograph/service.dart';
import 'package:contrast/utils/device.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../common/widgets/snack.dart';

/// Renders the photograph details view
class PhotographDetailsView extends HookConsumerWidget {
  /// Images list
  final List<ImageData> images;
  /// Initial selected photo index
  final int photoIndex;
  /// Current selected photograph category
  final String category;
  /// Audio player instance
  final AudioPlayer audio;

  const PhotographDetailsView({
    super.key,
    required this.images,
    required this.photoIndex,
    required this.category,
    required this.audio
  });

  /// Are coordinates valid or not
  bool _isAreCoordinatesValid(double? lat, double? lng) =>
      ((lat != null && lat != 0)
          && (lng != null && lng != 0))
          && (lat >= -90.0 && lat <= 90.0)
          && (lng >= -90.0 && lng <= 90.0);

  /// Sets the photograph detail button asset
  void _setPhotographDetailAsset(WidgetRef ref, ScrollController scrollController) {
    try {
      ref.read(photographDetailAssetProvider.notifier).setDetailAsset(
          scrollController.offset == 0 ? 'map.svg' : 'photo_light_weight.svg'
      );
    } catch (e) {
      ref.read(photographDetailAssetProvider.notifier).setDetailAsset('map.svg');
    }
  }

  /// Handles go to photograph details and go back to photograph action
  void _handlePhotographDetailsAction(WidgetRef ref, ScrollController scrollController, double scrollOffset) async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutExpo
      );
      _setPhotographDetailAsset(ref, scrollController);
    }
  }

  /// Moves the map to the location where the shot was taken
  void _handlePhotographShotLocation(WidgetRef ref) {
    final int photographIndex = ref.read(photographIndexProvider(photoIndex));
    final ImageData image = images[photographIndex];
    if (image.lat != null && image.lng != null) {
      ref.read(mapLatProvider.notifier).setCurrentLat(image.lat!);
      ref.read(mapLngProvider.notifier).setCurrentLng(image.lng!);
    }
  }

  /// Switches to the next photograph if there is such
  void _goToNextPhotograph(WidgetRef ref, PageController pageController, int currentPhotographIndex) {
    if (currentPhotographIndex + 1 < images.length) {
      pageController.animateToPage(
          currentPhotographIndex + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastEaseInToSlowEaseOut
      );
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(
          currentPhotographIndex + 1
      );
      ref.read(photographTitleVisibilityProvider.notifier).setVisibility(true);
      _handlePhotographShotLocation(ref);
      html.window.history.pushState(
          null,
          'photograph_details',
          '#/photos/details?id=${images[currentPhotographIndex + 1].id}&category=$category'
      );
    }
    if (currentPhotographIndex >= images.length) {
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(
          images.length - 1
      );
    }
    ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);
    ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(null);
  }

  /// Switches to the previous photograph if there is such
  void _goToPreviousPhotograph(WidgetRef ref, PageController pageController, int currentPhotographIndex) {
    if (currentPhotographIndex - 1 >= 0) {
      pageController.animateToPage(
          currentPhotographIndex - 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastEaseInToSlowEaseOut
      );
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(
          currentPhotographIndex - 1
      );
      ref.read(photographTitleVisibilityProvider.notifier).setVisibility(true);
      _handlePhotographShotLocation(ref);
      html.window.history.pushState(
          null,
          'photograph_details',
          '#/photos/details?id=${images[currentPhotographIndex - 1].id}&category=$category'
      );
    }
    if (currentPhotographIndex < 0) {
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(0);
    }
    ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);
    ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(null);
  }

  /// Handles the key events from the Focus widget and updates the page
  void _handleKeyEvent(KeyEvent event, WidgetRef ref, ScrollController scrollController, PageController pageController, int currentPhotographIndex) {
    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _goToPreviousPhotograph(ref, pageController, currentPhotographIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _goToNextPhotograph(ref, pageController, currentPhotographIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);
        ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(null);
        Modular.to.navigate('/');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _handlePhotographDetailsAction(ref, scrollController, scrollController.position.maxScrollExtent);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _handlePhotographDetailsAction(ref, scrollController, 0);
      }
    }
  }

  /// Renders the trip planning dialog
  Widget _renderTripPlanningOverlay(WidgetRef ref, ImageData image, bool shouldShowTripPlanningDialog) => Align(
    alignment: Alignment.bottomCenter,
    child: SlideTransitionAnimation(
        duration: const Duration(milliseconds: 1000),
        getStart: () => shouldShowTripPlanningDialog ? const Offset(0, 1) : const Offset(0, 0),
        getEnd: () => shouldShowTripPlanningDialog ? const Offset(0, 0) : const Offset(0, 10),
        whenTo: (controller) {
          useValueChanged(shouldShowTripPlanningDialog, (_, __) async {
            controller.reset();
            controller.forward();
          });
        },
        child: TripPlanningOverlay(image: image)
    ),
  );

  /// Renders the comments dialog
  Widget _renderCommentsOverlay(WidgetRef ref, ImageData image, bool shouldShowCommentsDialog) => Align(
    alignment: Alignment.bottomCenter,
    child: SlideTransitionAnimation(
        duration: const Duration(milliseconds: 1000),
        getStart: () => shouldShowCommentsDialog ? const Offset(0, 1) : const Offset(0, 0),
        getEnd: () => shouldShowCommentsDialog ? const Offset(0, 0) : const Offset(0, 10),
        whenTo: (controller) {
          useValueChanged(shouldShowCommentsDialog, (_, __) async {
            controller.reset();
            controller.forward();
          });
        },
        child: CommentDialog<ImageCommentsData>(
            widgetKey: const Key('comment_photograph'),
            parentItemId: image.id!,
            serviceProvider: imageCommentsDataViewProvider,
            itemBuilder: (BuildContext context, ImageCommentsData item, String? deviceId, int index) => Padding(
              padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
              child: Row(
                children: [
                  Container(
                    width: 5.0,
                    height: 5.0,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StyledText(
                                text: utf8.decode(item.deviceName!.runes.toList()),
                                fontSize: 15,
                                weight: FontWeight.bold,
                                clip: false,
                                align: TextAlign.start,
                                padding: 0,
                              ),
                              const SizedBox(width: 5),
                              if(item.rating! > 0) RatingBar.builder(
                                initialRating: item.rating!,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                ignoreGestures: true,
                                itemSize: 25,
                                glow: true,
                                itemCount: 5,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                              const Spacer(),
                              if (Session().isLoggedIn() && !item.approved!) DefaultButton(
                                  padding: 0,
                                  height: 25,
                                  onClick: () => ref.read(commentsServiceProvider).approvePhotographComment(item.id!).then((value) {
                                    ref.read(imageCommentsDataViewProvider.notifier).updateItem(item, value);
                                    showSuccessTextOnSnackBar(
                                        context.mounted
                                            ? context
                                            : null,
                                        translate('Comment approved')
                                    );
                                  }),
                                  tooltip: translate('Approve comment'),
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderColor: Colors.white,
                                  icon: 'check.svg'
                              ),
                              if (Session().isLoggedIn() && !item.approved!) const SizedBox(width: 20),
                              if (deviceId == item.deviceId || Session().isLoggedIn()) DefaultButton(
                                  padding: 0,
                                  height: 25,
                                  onClick: () => Session().isLoggedIn() ?
                                  ref.read(commentsServiceProvider).deletePhotographCommentAsAdmin(item.id!).then((value) {
                                    ref.read(imageCommentsDataViewProvider.notifier).removeItem(index);
                                    showSuccessTextOnSnackBar(
                                        context.mounted
                                            ? context
                                            : null,
                                        translate('Comment deleted')
                                    );
                                  }) :
                                  ref.read(commentsServiceProvider).deletePhotographComment(item.id!, deviceId!).then((value) {
                                    ref.read(imageCommentsDataViewProvider.notifier).removeItem(index);
                                    showSuccessTextOnSnackBar(
                                        context.mounted
                                            ? context
                                            : null,
                                        translate('Comment deleted')
                                    );
                                  }),
                                  tooltip: translate('Delete comment'),
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderColor: Colors.white,
                                  icon: 'delete.svg'
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: StyledText(
                              text: formatTimeDifference(context, item.date),
                              fontSize: 10,
                              color: Colors.black38,
                              weight: FontWeight.bold,
                              align: TextAlign.start,
                              letterSpacing: 3,
                              padding: 0,
                            ),
                          ),
                          StyledText(
                            text: utf8.decode(item.comment!.runes.toList()),
                            fontSize: 13,
                            clip: false,
                            align: TextAlign.start,
                            color: Colors.black87,
                            padding: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
    ),
  );

  /// Renders the photograph signature
  Widget _renderSignature(BuildContext context, String currentView) => SlideTransitionAnimation(
      duration: const Duration(milliseconds: 500),
      getStart: () => currentView == 'map.svg' ? const Offset(0, 1) : const Offset(0, 0),
      getEnd: () => currentView == 'map.svg' ? const Offset(0, 0) : const Offset(0, 1),
      whenTo: (controller) {
        useValueChanged(currentView, (_, __) async {
          controller.reset();
          controller.forward();
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15, bottom: 15),
        child: Align(
          alignment: Alignment.bottomRight,
          child: IconRenderer(
            asset: 'signature.svg',
            color: Colors.white,
            height: MediaQuery.of(context).size.shortestSide / 6,
          ),
        ),
      )
  );

  /// Render the photograph title
  Widget _renderPhotographTitle(BuildContext context, WidgetRef ref, int currentPhotographIndex) => Padding(
    padding: const EdgeInsets.only(top: kIsWeb ? 0 : 60),
    child: Align(
        alignment: Alignment.center,
        child: FadeAnimation(
          whenTo: (controller) => useValueChanged(currentPhotographIndex, (_, __) async {
            controller.reset();
            controller.forward();
          }),
          onCompleted: () => ref.read(photographTitleVisibilityProvider.notifier).setVisibility(false),
          start: 1,
          end: 0,
          duration: const Duration(milliseconds: 1200),
          child: StyledText(
            text: images[currentPhotographIndex].comment != null
                ? images[currentPhotographIndex].comment!
                : '',
            color: Colors.white,
            useShadow: true,
            fontSize: useMobileLayoutOriented(context) ? 25 : 62,
            clip: false,
            italic: true,
            weight: FontWeight.w100,
          ),
        )
    ),
  );

  /// Render the next photograph button
  Widget _renderNextBtn(WidgetRef ref, BuildContext context, PageController pageController, int currentPhotographIndex) => Padding(
    padding: const EdgeInsets.all(5.0),
    child: Align(
        alignment: Alignment.centerRight,
        child: DefaultButton(
            onClick: () => _goToNextPhotograph(ref, pageController, currentPhotographIndex),
            color: Colors.white,
            tooltip: translate('Next photograph'),
            borderColor: Colors.black,
            icon: 'navigate_next.svg'
        )
    ),
  );

  /// Render the previous photograph button
  Widget _renderPreviousBtn(WidgetRef ref, BuildContext context, PageController pageController, int currentPhotographIndex) => Padding(
    padding: const EdgeInsets.all(5.0),
    child: Align(
        alignment: Alignment.centerLeft,
        child: DefaultButton(
            onClick: () => _goToPreviousPhotograph(ref, pageController, currentPhotographIndex),
            color: Colors.white,
            tooltip: translate('Previous photograph'),
            borderColor: Colors.black,
            icon: 'navigate_before.svg'
        )
    ),
  );

  /// Render the go to previous page button
  Widget _renderGoBackBtn(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.all(5.0),
    child: Align(
        alignment: Alignment.topLeft,
        child: DefaultButton(
            onClick: () {
              ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);
              ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(null);
              Modular.to.navigate('/');
              },
            color: Colors.white,
            tooltip: translate('Close'),
            borderColor: Colors.black,
            icon: 'close.svg'
        )
    ),
  );

  /// Renders the audio button
  Widget _renderAudioButton(BuildContext context, WidgetRef ref) =>
      Padding(
        padding: const EdgeInsets.only(left: 115.0, top: 5.0),
        child: DefaultButton(
            onClick: () async {
              ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);
              if(audio.state != PlayerState.playing) {
                await audio.play(AssetSource('background_music.mp3'), position: await audio.getCurrentPosition() ?? const Duration(seconds: 0), mode: PlayerMode.lowLatency);
                ref.read(musicTriggerProvider.notifier).setPlay(true);
              } else {
                audio.pause();
                ref.read(musicTriggerProvider.notifier).setPlay(false);
              }
            },
            tooltip: ref.watch(musicTriggerProvider) ? translate('Stop music') : translate('Play music'),
            color: Colors.white,
            borderColor: Colors.black,
            icon: ref.watch(musicTriggerProvider) ? 'volume_up.svg' : 'volume_off.svg'
        ),
      );

  /// Renders the share button
  Widget _renderShareButton(BuildContext context, WidgetRef ref, int currentPhotographyIndex) =>
      Padding(
        padding: const EdgeInsets.only(left: 60.0, top: 5.0),
        child: DefaultButton(
            onClick: () {
              Clipboard.setData(
                  ClipboardData(
                      text: 'https://www.dstefomir.eu/#/photos/details?id=${images[currentPhotographyIndex].id}&category=$category')
              ).then((value) => showSuccessTextOnSnackBar(
                  context.mounted
                      ? context
                      : null,
                  translate('Copied to clipboard')
              ));
              ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);
              },
            tooltip: translate('Share'),
            color: Colors.white,
            borderColor: Colors.black,
            icon: 'share.svg'
        ),
      );

  /// Render the comments button
  Widget _renderCommentsBtn(WidgetRef ref, BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(left: kIsWeb ? 170.0 : 115, top: 5.0),
      child: Align(
          alignment: Alignment.topLeft,
          child: DefaultButton(
              onClick: () => ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(true),
              color: Colors.white,
              borderColor: Colors.black,
              tooltip: translate('Comments'),
              icon: 'comment.svg'
          )
      ),
    );
  }

  /// Renders the trip planning button
  Widget _renderTripPlanningBtn(WidgetRef ref, BuildContext context, ImageData image) {
    return SlideTransitionAnimation(
      duration: const Duration(milliseconds: 1000),
      getStart: () => _isAreCoordinatesValid(image.lat, image.lng) ? const Offset(0, -1) : const Offset(0, 0),
      getEnd: () => _isAreCoordinatesValid(image.lat, image.lng) ? const Offset(0, 0) : const Offset(0, -1),
      whenTo: (controller) {
        useValueChanged(_isAreCoordinatesValid(image.lat, image.lng), (_, __) async {
          controller.reset();
          controller.forward();
        });
      },
      child: Padding(
        padding: EdgeInsets.only(left: !Session().isLoggedIn() ? 225.0 : 280, top: 5.0),
        child: Align(
            alignment: Alignment.topLeft,
            child: DefaultButton(
                onClick: () => ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(true),
                color: Colors.white,
                borderColor: Colors.black,
                tooltip: translate('Trip planning'),
                icon: 'route.svg'
            )
        ),
      ),
    );
  }

  /// Render the details button
  Widget _renderDetailsBtn(WidgetRef ref, BuildContext context, ScrollController scrollController, ImageData image) {
    final String iconAsset = ref.watch(photographDetailAssetProvider);

    return SlideTransitionAnimation(
      duration: const Duration(milliseconds: 1000),
      getStart: () => _isAreCoordinatesValid(image.lat, image.lng) ? const Offset(0, -1) : const Offset(0, 0),
      getEnd: () => _isAreCoordinatesValid(image.lat, image.lng) ? const Offset(0, 0) : const Offset(0, -1),
      whenTo: (controller) {
        useValueChanged(_isAreCoordinatesValid(image.lat, image.lng), (_, __) async {
          controller.reset();
          controller.forward();
        });
      },
      child: Padding(
        padding: EdgeInsets.only(left: !kIsWeb ? 170 : !Session().isLoggedIn() ? 170.0 : 225, top: 5.0),
        child: Align(
            alignment: Alignment.topLeft,
            child: DefaultButton(
                onClick: () {
                  _handlePhotographDetailsAction(
                      ref,
                      scrollController,
                      scrollController.offset == 0 ? scrollController.position.maxScrollExtent : 0
                  );
                  ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(null);
                  ref.read(overlayVisibilityProvider(const Key('trip_planning_photograph')).notifier).setOverlayVisibility(null);
                  },
                color: Colors.white,
                borderColor: Colors.black,
                tooltip: iconAsset == 'map.svg' ? translate('Shot location') : translate('Photograph'),
                icon: iconAsset
            )
        ),
      ),
    );
  }

  /// Renders the photograph shot location
  Widget _renderPhotoDetails(BuildContext context, double maxWidth, maxHeight, double? lat, double? lng) =>
      _isAreCoordinatesValid(lat, lng) ?
      SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: ContrastMap(
              mapInteraction: getRunningPlatform(context) == 'MOBILE' ? InteractiveFlag.pinchZoom : InteractiveFlag.all
          )
      ) : const SizedBox.shrink();

  /// Renders the photography gallery widget
  Widget _renderPhotographGallery(
      BuildContext context,
      WidgetRef ref,
      ScrollController scrollController,
      PageController pageController,
      int currentPhotographIndex,
      ImageData image) {
    final serviceProvider = ref.watch(photographDetailsServiceProvider);

    return KeyboardListener(
      autofocus: true,
      focusNode: useFocusNode(),
      onKeyEvent: (event) => _handleKeyEvent(event, ref, scrollController, pageController, currentPhotographIndex),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ContrastPhotograph(
            widgetKey: Key('${image.id}_background'),
            fetch: (path) => serviceProvider.getPhotograph(path),
            image: image,
            quality: FilterQuality.low,
            borderColor: Colors.transparent,
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height
            ),
            fit: BoxFit.fill,
          ).blur(55, from: 0)
              .animate(
              trigger: true,
              duration: Duration.zero,
              startState: AnimationStartState.playImmediately
          ),
          PhotoViewGallery.builder(
            key: const Key('PhotographWidgetGallery'),
            scrollPhysics: const BouncingScrollPhysics(),
            allowImplicitScrolling: false,
            backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
            ),
            loadingBuilder: (context, chunk) => const Center(
              child: SizedBox(
                height: 400,
                child: LoadingIndicator(
                  indicatorType: Indicator.triangleSkewSpin,
                  colors: [Colors.white],
                  strokeWidth: 2,
                ),
              ),
            ),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: ExtendedNetworkImageProvider(
                  serviceProvider.getPhotograph(image.path!),
                  cache: true,
                  cacheKey: 'image_cache_key${image.id}_foreground',
                  imageCacheName: 'image_cache_name${image.id}_foreground',
                  cacheRawData: true,
                ),
                filterQuality: FilterQuality.high,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: image.id!),
              );
            },
            pageController: pageController,
            onPageChanged: (int page) async {
              if (kIsWeb) {
                await scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutExpo
                );
              }
              ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(page);
              ref.read(photographTitleVisibilityProvider.notifier).setVisibility(true);
              _handlePhotographShotLocation(ref);
              _setPhotographDetailAsset(ref, scrollController);
            },
            itemCount: images.length,
          ),
        ],
      )
    );
  }

  /// Render the main widget of the page
  Widget _renderPhotographWidget(
      BuildContext context,
      WidgetRef ref,
      PageController pageController,
      ScrollController scrollController,
      int currentPhotographIndex,
      ImageData image,
      double maxWidth, maxHeight) =>
      Align(
          alignment: Alignment.center,
          child: FadeAnimation(
              start: 0,
              end: 1,
              whenTo: (controller) =>
                  useValueChanged(currentPhotographIndex, (_, __) async {
                    controller.reset();
                    controller.forward();
                  }),
              child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      SizedBox(
                          width: maxWidth,
                          height: maxHeight,
                          child: _renderPhotographGallery(context, ref, scrollController, pageController, currentPhotographIndex, image)
                      ),
                      if (_isAreCoordinatesValid(image.lat, image.lng)) _renderPhotoDetails(context, maxWidth, maxHeight, image.lng, image.lat)
                    ],
                  )
              )
          )
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController pageController = usePageController(initialPage: photoIndex);
    final ScrollController scrollController = useScrollController();
    final int currentPhotographIndex = ref.watch(photographIndexProvider(photoIndex));
    final bool photographTitleVisibility = ref.watch(photographTitleVisibilityProvider);
    final String currentView = ref.watch(photographDetailAssetProvider);
    final ImageData? image = currentPhotographIndex != -1 ? images[currentPhotographIndex] : null;
    final double maxWidth = MediaQuery.of(context).size.width;
    final double maxHeight = MediaQuery.of(context).size.height;
    final bool? shouldShowCommentsDialog = ref.watch(overlayVisibilityProvider(const Key('comment_photograph')));
    final bool? shouldShowTripPlanningDialog = ref.watch(overlayVisibilityProvider(const Key('trip_planning_photograph')));

    return Stack(
        children: [
          if (image != null) _renderPhotographWidget(context, ref, pageController, scrollController, currentPhotographIndex, image, maxWidth, maxHeight),
          if (image != null) _renderDetailsBtn(ref, context, scrollController, image),
          if (!kIsWeb && image != null) _renderTripPlanningBtn(ref, context, image),
          if (image != null && !kIsWeb || Session().isLoggedIn()) _renderCommentsBtn(ref, context),
          if (kIsWeb) _renderAudioButton(context, ref),
          if (image != null) _renderShareButton(context, ref, currentPhotographIndex),
          _renderGoBackBtn(context, ref),
          Visibility(
              visible: image != null && currentPhotographIndex != 0 && ((!useMobileLayoutOriented(context) && !useMobileLayout(context) || kIsWeb)),
              child: _renderPreviousBtn(ref, context, pageController, currentPhotographIndex)
          ),
          Visibility(
              visible: image != null && currentPhotographIndex != images.length - 1 && ((!useMobileLayoutOriented(context) && !useMobileLayout(context) || kIsWeb)),
              child: _renderNextBtn(ref, context, pageController, currentPhotographIndex)
          ),
          if (image != null) Visibility(
              visible: photographTitleVisibility,
              child: _renderPhotographTitle(context, ref, currentPhotographIndex)
          ),
          if (image != null) _renderSignature(context, currentView),
          if (image != null && (!kIsWeb || Session().isLoggedIn()) && ((shouldShowCommentsDialog != null && shouldShowCommentsDialog) || (shouldShowTripPlanningDialog != null && shouldShowTripPlanningDialog))) const Blurrable(strength: 10),
          if (image != null && (!kIsWeb || Session().isLoggedIn()) && shouldShowCommentsDialog != null) _renderCommentsOverlay(ref, image, shouldShowCommentsDialog),
          if (image != null && !kIsWeb && shouldShowTripPlanningDialog != null) _renderTripPlanningOverlay(ref, image, shouldShowTripPlanningDialog)
        ]
    );
  }
}