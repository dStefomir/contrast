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

/// Renders the photograph details view
class PhotographDetailsView extends HookConsumerWidget {
  /// Constraints of the page
  final BoxConstraints constraints;
  /// Images list
  final List<ImageData> images;
  /// Initial selected photo index
  final int photoIndex;

  const PhotographDetailsView(
      {super.key,
      required this.constraints,
      required this.images,
      required this.photoIndex});

  /// Are coordinates valid or not
  bool _isAreCoordinatesValid(double? lat, double? lng) =>
      ((lat != null && lat != 0) && (lng != null && lng != 0)) && (lat >= -90.0 && lat <= 90.0) && (lng >= -90.0 && lng <= 90.0);

  /// Sets the photograph detail button asset
  void _setPhotographDetailAsset(WidgetRef ref, ScrollController scrollController) {
    try {
      ref.read(photographDetailAssetProvider.notifier).setDetailAsset(scrollController.offset == 0 ? 'map.svg' : 'photo.svg');
    } catch (e) {
      ref.read(photographDetailAssetProvider.notifier).setDetailAsset('map.svg');
    }
  }

  /// Handles go to photograph details and go back to photograph action
  void _handlePhotographDetailsAction(WidgetRef ref, ScrollController scrollController) async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(
          scrollController.offset == 0 ? scrollController.position.maxScrollExtent : 0,
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
    }
    if (currentPhotographIndex >= images.length) {
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(images.length - 1);
    }
    _handlePhotographShotLocation(ref);
  }

  /// Switches to the previous photograph if there is such
  void _goToPreviousPhotograph(WidgetRef ref, PageController pageController, int currentPhotographIndex) {
    if (currentPhotographIndex - 1 >= 0) {
      pageController.jumpToPage(currentPhotographIndex - 1);
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(currentPhotographIndex - 1);
    }
    if (currentPhotographIndex < 0) {
      ref.read(photographIndexProvider(photoIndex).notifier).setCurrentPhotographIndex(0);
    }
    _handlePhotographShotLocation(ref);
  }

  // Handles the key events from the Focus widget and updates the page
  void _handleKeyEvent(RawKeyEvent event, WidgetRef ref, ScrollController scrollController, PageController pageController, int currentPhotographIndex) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _goToPreviousPhotograph(ref, pageController, currentPhotographIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _goToNextPhotograph(ref, pageController, currentPhotographIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Modular.to.navigate('/');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _handlePhotographDetailsAction(ref, scrollController);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _handlePhotographDetailsAction(ref, scrollController);
      }
    }
  }

  /// Render the photograph title
  Widget _renderPhotographTitle(BuildContext context, int currentPhotographIndex) => Align(
      alignment: Alignment.center,
      child: FadeAnimation(
        whenTo: (controller) => useValueChanged(currentPhotographIndex, (_, __) async {
          controller.reset();
          controller.forward();
        }),
        start: 1,
        end: 0,
        duration: const Duration(milliseconds: 1200),
        child: StyledText(
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
  );

  /// Render the next photograph button
  Widget _renderNextBtn(WidgetRef ref, BuildContext context, PageController pageController, int currentPhotographIndex) => Align(
    alignment: Alignment.centerRight,
    child: RoundedButton(
        onClick: () => _goToNextPhotograph(ref, pageController, currentPhotographIndex),
        color: Colors.white,
        borderColor: Colors.black,
        icon: 'navigate_next.svg'
    )
  );

  /// Render the previous photograph button
  Widget _renderPreviousBtn(WidgetRef ref, BuildContext context, PageController pageController, int currentPhotographIndex) => Align(
    alignment: Alignment.centerLeft,
    child: RoundedButton(
        onClick: () => _goToPreviousPhotograph(ref, pageController, currentPhotographIndex),
        color: Colors.white,
        borderColor: Colors.black,
        icon: 'navigate_before.svg'
    )
  );

  /// Render the go to previous page button
  Widget _renderGoBackBtn() => Align(
    alignment: Alignment.topLeft,
    child: RoundedButton(
        onClick: () => Modular.to.navigate('/'),
        color: Colors.white,
        borderColor: Colors.black,
        icon: 'close.svg'
    )
  );

  /// Render the details button
  Widget _renderDetailsBtn(WidgetRef ref, BuildContext context, ScrollController scrollController) {
    final String iconAsset = ref.watch(photographDetailAssetProvider);

    return Align(
      alignment: Alignment.bottomCenter,
      child: RoundedButton(
          onClick: () => _handlePhotographDetailsAction(ref, scrollController),
          color: Colors.white,
          borderColor: Colors.black,
          icon: iconAsset
      )
    );
  }

  /// Renders the photograph shot location
  Widget _renderPhotoDetails(double? lat, double? lng) =>
      _isAreCoordinatesValid(lat, lng) ?
      SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: const ContrastMap()
      ) : Container();

  /// Renders the photography gallery widget
  Widget _renderPhotographGallery(WidgetRef ref, ScrollController scrollController, PageController pageController, int currentPhotographIndex, ImageData image) {
    final PhotoViewScaleStateController scaleController = ref.read(photographScaleProvider);
    final serviceProvider = ref.watch(photographDetailsServiceProvider);

    return RawKeyboardListener(
      autofocus: true,
      focusNode: useFocusNode(),
      onKey: (RawKeyEvent event) => _handleKeyEvent(event, ref, scrollController, pageController, currentPhotographIndex),
      child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          allowImplicitScrolling: true,
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
                imageProvider: ExtendedNetworkImageProvider(serviceProvider.getPhotograph(context, image.path!)),
                initialScale: PhotoViewComputedScale.contained,
                filterQuality: FilterQuality.high,
                scaleStateController: scaleController,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: index)
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
            _setPhotographDetailAsset(ref, scrollController);
          },
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          loadingBuilder: (context, event) {
            return Center(
              child: SizedBox(
                width: useMobileLayout(context)
                    ? constraints.maxHeight / 2
                    : constraints.maxWidth / 2,
                height: useMobileLayout(context)
                    ? constraints.maxHeight / 2
                    : constraints.maxWidth / 2,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  color: Colors.white,
                ),
              ),
            );
          }),
    );
  }

  /// Render the main widget of the page
  Widget _renderPhotographWidget(WidgetRef ref, PageController pageController, ScrollController scrollController, int currentPhotographIndex, ImageData image) =>
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
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: _renderPhotographGallery(ref, scrollController, pageController, currentPhotographIndex, image)
                      ),
                      Visibility(
                          visible: _isAreCoordinatesValid(image.lat, image.lng),
                          child: _renderPhotoDetails(image.lng, image.lat)
                      )
                    ],
                  )
              )
          )
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController pageController = usePageController();
    final ScrollController scrollController = useScrollController();
    final int currentPhotographIndex = ref.watch(photographIndexProvider(photoIndex));
    final ImageData image = images[currentPhotographIndex];

    return Stack(
      children: [
        _renderPhotographWidget(ref, pageController, scrollController, currentPhotographIndex, image),
        Visibility(
            visible: _isAreCoordinatesValid(image.lat, image.lng),
            child: _renderDetailsBtn(ref, context, scrollController)
        ),
        _renderGoBackBtn(),
        Visibility(
            visible: currentPhotographIndex != 0 && !useMobileLayout(context),
            child: _renderPreviousBtn(ref, context, pageController, currentPhotographIndex)
        ),
        Visibility(
            visible: currentPhotographIndex != images.length - 1 && !useMobileLayout(context),
            child: _renderNextBtn(ref, context, pageController, currentPhotographIndex)
        ),
        _renderPhotographTitle(context, currentPhotographIndex),
      ],
    );
  }
}
