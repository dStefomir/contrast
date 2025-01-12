import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/hover_provider.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/overlay.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/image_meta_data.dart';
import 'package:contrast/utils/date.dart';
import 'package:contrast/utils/device.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyper_effects/hyper_effects.dart';

/// Photograph displaying widget
class ContrastPhotograph extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// Photograph fetch function
  final String Function(String path)? fetch;
  /// Constraints of the holder page
  final BoxConstraints constraints;
  /// Quality of the displayed image
  final FilterQuality quality;
  /// How the photograph should be displayed
  final BoxFit? fit;
  /// Image data model object
  final ImageData? image;
  /// Should display a compressed image or not
  final bool compressed;
  /// Width of the image
  final double? width;
  /// Height of the image
  final double? height;
  /// Image data in bytes
  final Uint8List? data;
  /// Should the image be zoomable or not
  final bool shouldPinchZoom;
  /// Is the image a thumbnail
  final bool isThumbnail;

  final Widget? Function(ExtendedImageState)? loadImageState;

  const ContrastPhotograph({
    required this.widgetKey,
    required this.quality,
    required this.constraints,
    this.fetch,
    this.shouldPinchZoom = false,
    this.fit,
    this.image,
    this.compressed = true,
    this.width,
    this.height,
    this.data,
    this.isThumbnail = false,
    this.loadImageState
  }) : super(key: widgetKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String platform = getRunningPlatform(context);
    final bool isMobile = useMobileLayoutOriented(context);
    Widget photo;

    if (data == null) {
      photo = ExtendedImage.network(fetch!(image!.path!),
        key: widgetKey,
        width: width,
        height: !isThumbnail ? height : double.infinity,
        enableLoadState: loadImageState != null,
        loadStateChanged: loadImageState,
        fit: fit ?? (compressed
            ? image?.isLandscape != null && image!.isLandscape!
            ? BoxFit.fitWidth
            : BoxFit.fitHeight
            : BoxFit.contain),
        cache: true,
        cacheRawData: true,
        mode: ExtendedImageMode.gesture,
        enableSlideOutPage: true,
        clearMemoryCacheIfFailed: true,
        clearMemoryCacheWhenDispose: false,
        imageCacheName: kIsWeb ? "${widgetKey.toString()}_cache_name_${platform}_isMobile_$isMobile" : null,
        filterQuality: quality,
        isAntiAlias: !kIsWeb,
      );
    } else {
      photo = ExtendedImage.memory(
        data!,
        key: widgetKey,
        width: width,
        height: height,
        scale: 0.6,
        enableLoadState: false,
        fit: fit ?? BoxFit.contain,
        cacheRawData: false,
        filterQuality: quality,
        isAntiAlias: !kIsWeb,
      );
    }
    return AspectRatio(
      key: Key("${widgetKey.toString()}_aspect_ration_parent"),
      aspectRatio: isThumbnail ? 3 / 2 : image!.isLandscape! ? 2.3 / 2 : 2 / 2.3,
        child: photo
    );
  }
}

/// Image widget which shows a photo and its meta data
class ContrastPhotographMeta extends StatefulHookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// Photograph fetch function
  final String Function(String)? fetch;
  /// Image wrapper object
  final ImageBoardWrapper wrapper;
  /// Constraints of the parent page
  final BoxConstraints constraints;
  /// What happens when clicked on the widget
  final void Function() onClick;
  /// What happens when the user clicks the redirect button
  final Function? onRedirect;
  /// Color of the border of the photograph
  final Color borderColor;

  const ContrastPhotographMeta({
    required this.widgetKey,
    required this.wrapper,
    required this.constraints,
    required this.onClick,
    this.fetch,
    this.onRedirect,
    this.borderColor = Colors.black
  }) : super(key: widgetKey);

  @override
  ConsumerState createState() => _ContrastPhotographMetaState();
}

class _ContrastPhotographMetaState extends ConsumerState<ContrastPhotographMeta> {
  /// Overlay with photograph meta data
  OverlayEntry? popupDialog;

  /// Shows the popup overlay
  OverlayEntry _createPopupDialog(BuildContext context, bool isHovering) =>
      OverlayEntry(
          builder: (_) => BlurryContainer(
            child: AnimatedDialog(
                width: widget.constraints.maxWidth + 150,
                height: widget.constraints.maxHeight + 150,
                child: _renderPhoto(
                    context,
                    ImageMetaDataDetails(
                      constraints: widget.constraints,
                      metadata: widget.wrapper.metadata,
                      isLandscape: widget.wrapper.image.isLandscape!,
                      scaleFactor: 10,
                      onTap: widget.onClick,
                    ),
                    false
                )
            ),
          )
      );

  /// Renders a photograph
  Widget _renderPhoto(BuildContext context, Widget? metadata, bool shouldHaveBorder) {
    final bool isHovering = ref.watch(hoverProvider(widget.widgetKey));
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Stack(
        key: Key("${widget.widgetKey.toString()}_stack_photograph"),
        alignment: Alignment.center,
        children: [
          ContrastPhotograph(
            widgetKey: Key("${widget.widgetKey.toString()}_photograph"),
            fetch: widget.fetch,
            constraints: widget.constraints,
            quality: FilterQuality.low,
            fit: BoxFit.cover,
            image: widget.wrapper.image,
            compressed: true,
            width: double.infinity,
            height: double.infinity,
            loadImageState: metadata == null ? (state) {
              if (state.extendedImageLoadState == LoadState.completed) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.5)
                  ),
                  child: ExtendedRawImage(
                    image: state.extendedImageInfo?.image,
                    fit: BoxFit.cover,
                  ),
                ).scaleOut(start: 0.8, end: 1).animate(
                    curve: Curves.easeInOut,
                    trigger: true,
                    duration: const Duration(milliseconds: 600),
                    startState: AnimationStartState.playImmediately
                );
              }

              return const SizedBox.shrink();
            } : null,
          ),
          if (metadata != null) metadata,
          if (isHovering) ImageMetaDataDetails(
            constraints: widget.constraints,
            metadata: widget.wrapper.metadata,
            isLandscape: widget.wrapper.image.isLandscape!,
            onTap: widget.onClick,
            scaleFactor: 16,
          ).translateOnPhotoHover,
          if (isHovering && widget.onRedirect != null && getRunningPlatform(context) == 'DESKTOP')
            Align(
                alignment: Alignment.topRight,
                child: RedirectButton(
                  widgetKey: Key("${widget.widgetKey.toString()}_photograph_redirect"),
                  constraints: widget.constraints,
                  onRedirect: widget.onRedirect!,
                  height: widget.constraints.maxHeight / 7,
                )
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoWidget = _renderPhoto(context, null, true);
    renderMobileWidget(Widget child) => GestureDetector(
      onTap: widget.onClick,
      onLongPressStart: (details) {
        final bool isHovering = ref.watch(hoverProvider(widget.widgetKey));
        if (!isHovering && popupDialog == null) {
          popupDialog = _createPopupDialog(context, isHovering);
          Overlay.of(context).insert(popupDialog!);
        }
      },
      onLongPressEnd: (details) {
        popupDialog?.remove();
        popupDialog = null;
      },
      child: child
    );
    renderWebWidget(Widget child) => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onClick(),
        onHover: (hover) => ref.read(hoverProvider(widget.widgetKey).notifier).onHover(hover),
        hoverColor: Colors.black,
        child: renderMobileWidget(child),
      ),
    );
    return kIsWeb ? renderWebWidget(photoWidget) : renderMobileWidget(photoWidget);
  }
}

/// Image metadata widget
class ImageMetaDataDetails extends StatelessWidget {
  /// Constraints of the parent page
  final BoxConstraints constraints;
  /// Image metadata object
  final ImageMetaData metadata;
  /// Text scale factor
  final double scaleFactor;
  /// Is the image landscape or not
  final bool isLandscape;
  /// Should be rendered in a row not
  final bool row;
  /// What happens when the user clicks the text
  final void Function() onTap;

  const ImageMetaDataDetails({
    required this.constraints,
    required this.metadata,
    required this.onTap,
    required this.isLandscape,
    this.scaleFactor = 20,
    this.row = false,
    super.key
  });

  /// Renders a photograph meta row
  Row _renderMetaRow(BuildContext context, String? text, String icon) {
    final double metaIconSize = constraints.maxWidth / scaleFactor;
    final double metaFontSize = constraints.maxWidth / scaleFactor;

    return Row(
      children: [
        ShadowWidget(
            shouldHaveBorderRadius: true,
            offset: const Offset(0, 0),
            blurRadius: 20,
            child: IconRenderer(
                asset: icon, color: Colors.white, height: metaIconSize
            )
        ),
        StyledText(
          text: text != null
              ? text.length > 13
              ? text.substring(0, 14)
              : text
              : '',
          color: Colors.white,
          useShadow: true,
          fontSize: metaFontSize,
          typewriter: true,
          onTypewriterTap: onTap,
          typewriterCursor: false,
          padding: 5,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [
      if (row) const Spacer(),
      Visibility(
        visible: metadata.camera != null,
        child: _renderMetaRow(context, metadata.camera ?? '', 'camera.svg'),
      ),
      if (row) const Spacer(),
      Visibility(
        visible: metadata.fStop != null,
        child: _renderMetaRow(context, metadata.fStop ?? '', 'apperature.svg'),
      ),
      if (row) const Spacer(),
      Visibility(
        visible: metadata.exposureTime != null,
        child: _renderMetaRow(context, metadata.exposureTime ?? '', 'shutter_speed.svg'),
      ),
      if (row) const Spacer(),
      Visibility(
        visible: metadata.lens != null,
        child: _renderMetaRow(
          context,
          metadata.lens ?? '',
          'lens.svg',
        ),
      ),
      if (row) const Spacer(),
      Visibility(
        visible: metadata.dataOfCapture != null,
        child: _renderMetaRow(
          context,
          formatDateUi(
              metadata.dataOfCapture),
          'date.svg',
        ),
      ),
      if (row) const Spacer(),
    ];

    return Padding(
      padding: EdgeInsets.only(
          left: constraints.maxWidth / 30, top: constraints.maxWidth / 30),
      child: row
          ? Row(children: widgets)
          : Column(children: widgets),
    );
  }
}