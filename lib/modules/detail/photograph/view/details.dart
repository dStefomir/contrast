import 'package:audioplayers/audioplayers.dart';
import 'package:contrast/common/widgets/blur.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/overlay/comment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
      ((lat != null && lat != 0) && (lng != null && lng != 0)) && (lat >= -90.0 && lat <= 90.0) && (lng >= -90.0 && lng <= 90.0);

  /// Sets the photograph detail button asset
  void _setPhotographDetailAsset(WidgetRef ref, ScrollController scrollController) {
    try {
      ref.read(photographDetailAssetProvider.notifier).setDetailAsset(scrollController.offset == 0 ? 'map.svg' : 'photo_light_weight.svg');
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
      pageController.jumpToPage(currentPhotographIndex + 1);
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(currentPhotographIndex + 1);
      ref.read(photographTitleVisibilityProvider.notifier).setVisibility(true);
      _handlePhotographShotLocation(ref);
      html.window.history.pushState(null, 'photograph_details', '#/photos/details?id=${images[currentPhotographIndex + 1].id}&category=$category');
    }
    if (currentPhotographIndex >= images.length) {
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(images.length - 1);
    }
    ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(false);
  }

  /// Switches to the previous photograph if there is such
  void _goToPreviousPhotograph(WidgetRef ref, PageController pageController, int currentPhotographIndex) {
    if (currentPhotographIndex - 1 >= 0) {
      pageController.jumpToPage(currentPhotographIndex - 1);
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(currentPhotographIndex - 1);
      ref.read(photographTitleVisibilityProvider.notifier).setVisibility(true);
      _handlePhotographShotLocation(ref);
      html.window.history.pushState(null, 'photograph_details', '#/photos/details?id=${images[currentPhotographIndex - 1].id}&category=$category');
    }
    if (currentPhotographIndex < 0) {
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(0);
    }
    ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(false);
  }

  // Handles the key events from the Focus widget and updates the page
  void _handleKeyEvent(RawKeyEvent event, WidgetRef ref, ScrollController scrollController, PageController pageController, int currentPhotographIndex) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _goToPreviousPhotograph(ref, pageController, currentPhotographIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _goToNextPhotograph(ref, pageController, currentPhotographIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(false);
        Modular.to.navigate('/');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _handlePhotographDetailsAction(ref, scrollController, scrollController.position.maxScrollExtent);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _handlePhotographDetailsAction(ref, scrollController, 0);
      }
    }
  }

  /// Renders the photograph signature
  Widget _renderSignature(double maxHeight, String currentView) => SlideTransitionAnimation(
      key: const Key('PhotographDetailsSignatureSlideAnimation'),
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
        key: const Key('PhotographDetailsSignaturePadding'),
        padding: const EdgeInsets.only(right: 15, bottom: 15),
        child: Align(
          key: const Key('PhotographDetailsSignatureAlign'),
          alignment: Alignment.bottomRight,
          child: IconRenderer(
            key: const Key('PhotographDetailsSignatureSvg'),
            asset: 'signature.svg',
            color: Colors.white,
            height: maxHeight / 10,
          ),
        ),
      )
  );

  /// Render the photograph title
  Widget _renderPhotographTitle(BuildContext context, WidgetRef ref, int currentPhotographIndex) => Padding(
    key: const Key('PhotographDetailsTitlePadding'),
    padding: const EdgeInsets.only(top: kIsWeb ? 0 : 60),
    child: Align(
        key: const Key('PhotographDetailsTitleAlign'),
        alignment: Alignment.center,
        child: FadeAnimation(
          key: const Key('PhotographDetailsTitleFadeAnimation'),
          whenTo: (controller) => useValueChanged(currentPhotographIndex, (_, __) async {
            controller.reset();
            controller.forward();
          }),
          onCompleted: () => ref.read(photographTitleVisibilityProvider.notifier).setVisibility(false),
          start: 1,
          end: 0,
          duration: const Duration(milliseconds: 1200),
          child: StyledText(
            key: const Key('PhotographDetailsTitleText'),
            text: images[currentPhotographIndex].comment != null
                ? images[currentPhotographIndex].comment!
                : '',
            color: Colors.white,
            useShadow: true,
            fontSize: useMobileLayout(context) ? 25 : 62,
            clip: false,
            italic: true,
            weight: FontWeight.w100,
          ),
        )
    ),
  );

  /// Render the next photograph button
  Widget _renderNextBtn(WidgetRef ref, BuildContext context, PageController pageController, int currentPhotographIndex) => Padding(
    key: const Key('PhotographDetailsNextButtonPadding'),
    padding: const EdgeInsets.all(5.0),
    child: Align(
        key: const Key('PhotographDetailsNextButtonAlign'),
        alignment: Alignment.centerRight,
        child: DefaultButton(
            key: const Key('PhotographDetailsNextButton'),
            onClick: () => _goToNextPhotograph(ref, pageController, currentPhotographIndex),
            color: Colors.white,
            tooltip: FlutterI18n.translate(context, 'Next photograph'),
            borderColor: Colors.black,
            icon: 'navigate_next.svg'
        )
    ),
  );

  /// Render the previous photograph button
  Widget _renderPreviousBtn(WidgetRef ref, BuildContext context, PageController pageController, int currentPhotographIndex) => Padding(
    key: const Key('PhotographDetailsPreviousButtonPadding'),
    padding: const EdgeInsets.all(5.0),
    child: Align(
        key: const Key('PhotographDetailsPreviousButtonAlign'),
        alignment: Alignment.centerLeft,
        child: DefaultButton(
            key: const Key('PhotographDetailsPreviousButton'),
            onClick: () => _goToPreviousPhotograph(ref, pageController, currentPhotographIndex),
            color: Colors.white,
            tooltip: FlutterI18n.translate(context, 'Previous photograph'),
            borderColor: Colors.black,
            icon: 'navigate_before.svg'
        )
    ),
  );

  /// Render the go to previous page button
  Widget _renderGoBackBtn(BuildContext context, WidgetRef ref) => Padding(
    key: const Key('PhotographDetailsGoBackButtonPadding'),
    padding: const EdgeInsets.all(5.0),
    child: Align(
        key: const Key('PhotographDetailsGoBackButtonAlign'),
        alignment: Alignment.topLeft,
        child: DefaultButton(
            key: const Key('PhotographDetailsGoBackButton'),
            onClick: () {
              ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(false);
              Modular.to.navigate('/');
              },
            color: Colors.white,
            tooltip: FlutterI18n.translate(context, 'Close'),
            borderColor: Colors.black,
            icon: 'close.svg'
        )
    ),
  );

  /// Renders the audio button
  Widget _renderAudioButton(BuildContext context, WidgetRef ref) =>
      Padding(
        key: const Key('PhotographDetailsAudioButtonPadding'),
        padding: const EdgeInsets.only(left: 115.0, top: 5.0),
        child: DefaultButton(
            key: const Key('PhotographDetailsAudioButton'),
            onClick: () async {
              ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(false);
              if(audio.state != PlayerState.playing) {
                await audio.play(AssetSource('background_music.mp3'), position: await audio.getCurrentPosition() ?? const Duration(seconds: 0), mode: PlayerMode.lowLatency);
                ref.read(musicTriggerProvider.notifier).setPlay(true);
              } else {
                audio.pause();
                ref.read(musicTriggerProvider.notifier).setPlay(false);
              }
            },
            tooltip: ref.watch(musicTriggerProvider) ? FlutterI18n.translate(context, 'Stop music') : FlutterI18n.translate(context, 'Play music'),
            color: Colors.white,
            borderColor: Colors.black,
            icon: ref.watch(musicTriggerProvider) ? 'volume_up.svg' : 'volume_off.svg'
        ),
      );

  /// Renders the share button
  Widget _renderShareButton(BuildContext context, WidgetRef ref, int currentPhotographyIndex) =>
      Padding(
        key: const Key('PhotographDetailsShareButtonPadding'),
        padding: const EdgeInsets.only(left: 60.0, top: 5.0),
        child: DefaultButton(
            key: const Key('PhotographDetailsShareButton'),
            onClick: () {
              Clipboard.setData(
                  ClipboardData(
                      text: 'https://www.dstefomir.eu/#/photos/details?id=${images[currentPhotographyIndex].id}&category=$category')
              ).then((value) => showSuccessTextOnSnackBar(
                  context,
                  FlutterI18n.translate(context, 'Copied to clipboard')
              ));
              ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(false);
              },
            tooltip: FlutterI18n.translate(context, 'Share'),
            color: Colors.white,
            borderColor: Colors.black,
            icon: 'share.svg'
        ),
      );

  /// Render the comments button
  Widget _renderCommentsBtn(WidgetRef ref, BuildContext context) {

    return Padding(
      key: const Key('PhotographCommentsButtonPadding'),
      padding: const EdgeInsets.only(left: 170.0, top: 5.0),
      child: Align(
          key: const Key('PhotographCommentsButtonAlign'),
          alignment: Alignment.topLeft,
          child: DefaultButton(
              key: const Key('PhotographCommentsButton'),
              onClick: () => ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(true),
              color: Colors.white,
              borderColor: Colors.black,
              tooltip: FlutterI18n.translate(context, 'Comments'),
              icon: 'comment.svg'
          )
      ),
    );
  }

  /// Render the details button
  Widget _renderDetailsBtn(WidgetRef ref, BuildContext context, ScrollController scrollController, ImageData image) {
    final String iconAsset = ref.watch(photographDetailAssetProvider);

    return SlideTransitionAnimation(
      key: const Key('PhotographDetailsButtonSlideAnimation'),
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
        key: const Key('PhotographDetailsButtonPadding'),
        padding: const EdgeInsets.only(left: 225.0, top: 5.0),
        child: Align(
            key: const Key('PhotographDetailsButtonAlign'),
            alignment: Alignment.topLeft,
            child: DefaultButton(
                key: const Key('PhotographDetailsButton'),
                onClick: () {
                  _handlePhotographDetailsAction(
                      ref,
                      scrollController,
                      scrollController.offset == 0 ? scrollController.position.maxScrollExtent : 0
                  );
                  ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(false);
                  },
                color: Colors.white,
                borderColor: Colors.black,
                tooltip: iconAsset == 'map.svg' ? FlutterI18n.translate(context, 'Shot location') : FlutterI18n.translate(context, 'Photograph'),
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
          key: const Key('PhotographDetailsSizedBox'),
          width: maxWidth,
          height: maxHeight,
          child: ContrastMap(
              key: const Key('PhotographDetailsMap'),
              mapInteraction: getRunningPlatform(context) == 'MOBILE' ? InteractiveFlag.pinchZoom : InteractiveFlag.all
          )
      ) : const SizedBox.shrink(key: Key('PhotographDetailsMapNone'));

  /// Renders the photography gallery widget
  Widget _renderPhotographGallery(
      BuildContext context,
      WidgetRef ref,
      ScrollController scrollController,
      PageController pageController,
      int currentPhotographIndex,
      ImageData image) {
    final serviceProvider = ref.watch(photographDetailsServiceProvider);

    return RawKeyboardListener(
      key: const Key('PhotographWidgetKeyboardListener'),
      autofocus: true,
      focusNode: useFocusNode(),
      onKey: (RawKeyEvent event) => _handleKeyEvent(event, ref, scrollController, pageController, currentPhotographIndex),
      child: PhotoViewGallery.builder(
          key: const Key('PhotographWidgetGallery'),
          scrollPhysics: const BouncingScrollPhysics(),
          allowImplicitScrolling: true,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          loadingBuilder: (_, chunk) => Center(
              key: const Key('PhotographWidgetGalleryLoadingCenter'),
              child: Padding(
                key: const Key('PhotographWidgetGalleryLoadingPadding'),
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height - 8),
                child: LinearProgressIndicator(
                  key: const Key('PhotographWidgetGalleryLoadingProgressIndicator'),
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  value: (chunk?.cumulativeBytesLoaded ?? 0) / 100,
                ),
              )
          ),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              key: const Key('PhotographWidgetGalleryOptions'),
                imageProvider: ExtendedNetworkImageProvider(serviceProvider.getPhotograph(image.path!)),
                filterQuality: FilterQuality.high,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: index),
            );
          },
          pageController: pageController,
          onPageChanged: (int page) async {
            ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(page);
            await scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutExpo
            );
            _handlePhotographShotLocation(ref);
            ref.read(photographTitleVisibilityProvider.notifier).setVisibility(true);
            _setPhotographDetailAsset(ref, scrollController);
          },
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
      ),
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
          key: const Key('PhotographWidgetAlign'),
          alignment: Alignment.center,
          child: FadeAnimation(
              key: const Key('PhotographWidgetFadeAnimation'),
              start: 0,
              end: 1,
              whenTo: (controller) =>
                  useValueChanged(currentPhotographIndex, (_, __) async {
                    controller.reset();
                    controller.forward();
                  }),
              child: SingleChildScrollView(
                  key: const Key('PhotographWidgetScrollView'),
                  controller: scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    key: const Key('PhotographWidgetColumn'),
                    children: [
                      SizedBox(
                          key: const Key('PhotographWidgetSizedBox'),
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
    final ImageData image = images[currentPhotographIndex];
    final double maxWidth = MediaQuery.of(context).size.width;
    final double maxHeight = MediaQuery.of(context).size.height;
    final bool? shouldShowCommentsDialog = ref.watch(overlayVisibilityProvider(const Key('comment_photograph')));

    return Stack(
        key: const Key('PhotographDetailsStack'),
        children: [
          IconRenderer(
              key: const Key('PhotographDetailsStackBackgroundSvg'),
              asset: 'background.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              color: Colors.white.withOpacity(0.05)
          ),
          getRunningPlatform(context) == 'MOBILE' ?
          GestureDetector(
              key: const Key('PhotographDetailsStackGesture'),
              onVerticalDragUpdate: (details) {
                const sensitivity = 2000.0;
                final deltaY = details.delta.dy * sensitivity;
                if (deltaY > 0) {
                  /// If the view is to the photograph and the scrolls up - pop up the page.
                  /// If not - scroll to the map
                  if(scrollController.position.pixels == 0) {
                    Modular.to.pop();
                  } else {
                    _handlePhotographDetailsAction(ref, scrollController, 0);
                  }
                } else {
                  _handlePhotographDetailsAction(ref, scrollController, scrollController.position.maxScrollExtent);
                }},
              child: _renderPhotographWidget(context, ref, pageController, scrollController, currentPhotographIndex, image, maxWidth, maxHeight)
          ) :
          _renderPhotographWidget(context, ref, pageController, scrollController, currentPhotographIndex, image, maxWidth, maxHeight),
          _renderDetailsBtn(ref, context, scrollController, image),
          _renderCommentsBtn(ref, context),
          _renderAudioButton(context, ref),
          _renderShareButton(context, ref, currentPhotographIndex),
          _renderGoBackBtn(context, ref),
          Visibility(
              key: const Key('PhotographDetailsPreviousVisibility'),
              visible: currentPhotographIndex != 0 && !useMobileLayout(context),
              child: _renderPreviousBtn(ref, context, pageController, currentPhotographIndex)
          ),
          Visibility(
              key: const Key('PhotographDetailsNextVisibility'),
              visible: currentPhotographIndex != images.length - 1 && !useMobileLayout(context),
              child: _renderNextBtn(ref, context, pageController, currentPhotographIndex)
          ),
          Visibility(
              key: const Key('PhotographDetailsTitleVisibility'),
              visible: photographTitleVisibility,
              child: _renderPhotographTitle(context, ref, currentPhotographIndex)
          ),
          _renderSignature(maxHeight, currentView),
          Visibility(
            key: const Key('BlurableDetailsPageVisible'),
            visible: shouldShowCommentsDialog != null && shouldShowCommentsDialog,
            child: const Blurrable(key: Key('BlurableDetailsPage'), strength: 10),
          ),
          if (shouldShowCommentsDialog != null) Align(
            key: const Key('CommentsDialogAlign'),
            alignment: Alignment.bottomCenter,
            child: SlideTransitionAnimation(
                key: const Key('CommentsDialogSlideAnimation'),
                duration: const Duration(milliseconds: 1000),
                getStart: () => shouldShowCommentsDialog ? const Offset(0, 1) : const Offset(0, 0),
                getEnd: () => shouldShowCommentsDialog ? const Offset(0, 0) : const Offset(0, 10),
                whenTo: (controller) {
                  useValueChanged(shouldShowCommentsDialog, (_, __) async {
                    controller.reset();
                    controller.forward();
                  });
                },
                child: CommentDialog(key: const Key('PhotographDetailsPageCommentDialog'), photographId: image.id!)
            ),
          )
        ]
    );
  }
}