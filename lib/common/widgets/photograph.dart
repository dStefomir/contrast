import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/hover_provider.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/load.dart';
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

/// Photograph displaying widget
class ContrastPhotograph extends StatelessWidget {
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
  /// Color of the border of the image
  final Color borderColor;
  /// Custom border of the photograph
  final BoxBorder? customBorder;
  /// Image border width
  final double borderWidth;
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

  const ContrastPhotograph({
    required this.widgetKey,
    required this.quality,
    required this.borderColor,
    required this.constraints,
    this.fetch,
    this.shouldPinchZoom = false,
    this.fit,
    this.image,
    this.compressed = true,
    this.customBorder,
    this.width,
    this.height,
    this.data,
    this.borderWidth = 1.5,
    this.isThumbnail = false,
  }) : super(key: widgetKey);

  /// Renders a widget based on the photograph state
  Widget _renderPhotographState(BuildContext context, ExtendedImageState state, String platform) {
    double shadowWidth = 0;
    double shadowHeight = 0;
    double paddingTop = 0;
    double paddingBottom = 0;
    double paddingLeft = 0;
    double paddingRight = 0;

    if (isThumbnail) {
      shadowWidth = constraints.maxWidth;
      shadowHeight = constraints.maxHeight / 1.34;
    } else {
      if (image!.isLandscape!) {
        paddingRight = 1.5;
        paddingLeft = 1.5;
        shadowWidth = constraints.maxWidth - (paddingRight + paddingLeft);
        shadowHeight = constraints.maxHeight / 1.5 - 2;
      } else {
        paddingTop = 1.5;
        paddingBottom = 1.5;
        shadowWidth = constraints.maxWidth / 1.5 - 2;
        shadowHeight = constraints.maxHeight - (paddingTop + paddingBottom);
      }
    }

    final Widget photograph = Stack(
      alignment: Alignment.center,
      children: [
        ShadowWidget(
            offset: const Offset(0, 0),
            blurRadius: isThumbnail ? 10: 3,
            child: SizedBox(
              width: shadowWidth,
              height: shadowHeight,
            )
        ),
        Padding(
          padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom, left: paddingLeft, right: paddingRight),
          child: AspectRatio(
            aspectRatio: isThumbnail || image!.isLandscape! ? 3 / 2 : 2 / 3,
            child: ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: width,
              height: !isThumbnail ? height : double.infinity,
              fit: fit ?? (compressed
                  ? image?.isLandscape != null && image!.isLandscape!
                  ? BoxFit.fitWidth
                  : BoxFit.fitHeight
                  : BoxFit.contain),
              isAntiAlias: true,
              filterQuality: quality,
            ),
          ),
        ),
      ],
    );

    if(state.extendedImageLoadState == LoadState.completed) {
      if(!kIsWeb) {
        return FadeAnimation(
            key: Key('${widgetKey.toString()}_rawImage'),
            start: 0,
            end: 1,
            duration: const Duration(milliseconds: 400),
            child: photograph
        );
      }
      return photograph;
    } else if(state.extendedImageLoadState == LoadState.loading) {
      return LoadingIndicator(
          color: Colors.grey,
          stroke: 2,
          width: constraints.maxWidth / 8,
          height: constraints.maxHeight / 8
      );
    }

    return photograph;
  }

  @override
  Widget build(BuildContext context) {
    final String platform = getRunningPlatform(context);
    Widget photo;

    if (data == null) {
      photo = ExtendedImage.network(fetch!(image!.path!),
        width: width,
        height: !isThumbnail ? height : double.infinity,
        border: customBorder ?? Border.all(color: borderColor, width: borderWidth),
        enableLoadState: !compressed,
        fit: fit ?? (compressed
            ? image?.isLandscape != null && image!.isLandscape!
            ? BoxFit.fitWidth
            : BoxFit.fitHeight
            : BoxFit.contain),
        cache: true,
        loadStateChanged: (ExtendedImageState state) => _renderPhotographState(context, state, platform),
        enableMemoryCache: true,
        cacheRawData: true,
        cacheKey: "${widgetKey.toString()}_cache_key_$platform",
        clearMemoryCacheIfFailed: true,
        clearMemoryCacheWhenDispose: false,
        filterQuality: quality,
        isAntiAlias: true,
      );
    } else {
      photo = ExtendedImage.memory(
        data!,
        width: width,
        height: height,
        scale: 0.6,
        border: customBorder ?? Border.all(color: borderColor, width: borderWidth),
        loadStateChanged: (ExtendedImageState state) => _renderPhotographState(context, state, platform),
        enableLoadState: !compressed,
        fit: fit ?? BoxFit.contain,
        enableMemoryCache: true,
        cacheRawData: true,
        clearMemoryCacheIfFailed: true,
        clearMemoryCacheWhenDispose: false,
        filterQuality: quality,
        isAntiAlias: true,
      );
    }

    return photo;
  }
}

/// Image widget which shows a photo and its meta data
class ContrastPhotographMeta extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// Photograph fetch function
  final String Function(String)? fetch;
  /// Image wrapper object
  final ImageBoardWrapper wrapper;
  /// Constraints of the parent page
  final BoxConstraints constraints;
  /// What happens when clicked on the widget
  final Function onClick;
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

  /// Shows the popup overlay
  OverlayEntry _createPopupDialog(BuildContext context, Widget? metadata, bool isHovering) =>
      OverlayEntry(
          builder: (context) => AnimatedDialog(
              width: constraints.maxWidth + 150,
              height: constraints.maxHeight + 150,
              child: _renderPhoto(
                  context,
                  ImageMetaDataDetails(
                    constraints: constraints,
                    metadata: wrapper.metadata,
                    scaleFactor: 10,
                  ),
                  isHovering
              )
          )
      );

  /// Renders a photograph
  Widget _renderPhoto(BuildContext context, Widget? metadata, bool isHovering) =>
      Stack(
        alignment: Alignment.center,
        children: [
          ContrastPhotograph(
            widgetKey: Key("${widgetKey.toString()}_photograph"),
            fetch: fetch,
            constraints: constraints,
            quality: FilterQuality.low,
            borderColor: borderColor,
            image: wrapper.image,
            borderWidth: 1.5,
            compressed: true,
            height: double.infinity,
            width: double.infinity,
          ),
          if (metadata != null) metadata,
          if(isHovering) ImageMetaDataDetails(
            constraints: constraints,
            metadata: wrapper.metadata,
            scaleFactor: 16,
          ).translateOnPhotoHover,
          if (isHovering && onRedirect != null && getRunningPlatform(context) == 'DESKTOP')
            Align(
                alignment: Alignment.topRight,
                child: RedirectButton(
                  widgetKey: Key("${widgetKey.toString()}_photograph_redirect"),
                  constraints: constraints,
                  onRedirect: onRedirect!,
                  height: constraints.maxHeight / 7,
                )
            ),
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late OverlayEntry? popupDialog;
    final bool isHovering = ref.watch(hoverProvider(widgetKey));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
        hoverColor: Colors.black,
        child: GestureDetector(
            onTap: () => onClick(),
            onLongPress: () {
              if (!isHovering) {
                popupDialog = _createPopupDialog(context, null, isHovering);
                Overlay.of(context).insert(popupDialog!);
              }
            },
            onLongPressEnd: (details) {
              if (!isHovering) {
                popupDialog?.remove();
              }
            },
            child: _renderPhoto(context, null, isHovering)
        ),
      ),
    );
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
  /// Should be rendered in a row
  final bool row;

  const ImageMetaDataDetails({
    required this.constraints,
    required this.metadata,
    this.scaleFactor = 20,
    this.row = false,
    super.key
  });

  /// Renders a photograph meta row
  Row _renderMetaRow(String? text, String icon) {
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
          padding: 5,
        ),
        if(!row)const Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [
      if(row) const Spacer(),
      Visibility(
        visible: metadata.camera != null,
        child: _renderMetaRow(metadata.camera ?? '', 'camera.svg'),
      ),
      if(row) const Spacer(),
      Visibility(
        visible: metadata.fStop != null,
        child: _renderMetaRow(metadata.fStop ?? '', 'apperature.svg'),
      ),
      if(row) const Spacer(),
      Visibility(
        visible: metadata.exposureTime != null,
        child: _renderMetaRow(metadata.exposureTime ?? '', 'shutter_speed.svg'),
      ),
      if(row) const Spacer(),
      Visibility(
        visible: metadata.lens != null,
        child: _renderMetaRow(
          metadata.lens ?? '',
          'lens.svg',
        ),
      ),
      if(row) const Spacer(),
      Visibility(
        visible: metadata.dataOfCapture != null,
        child: _renderMetaRow(
          formatDateUi(
              metadata.dataOfCapture != null ? metadata.dataOfCapture! : null),
          'date.svg',
        ),
      ),
      if(row) const Spacer(),
    ];

    return Padding(
      padding: EdgeInsets.only(
          left: constraints.maxWidth / 30, top: constraints.maxWidth / 30),
      child: row
          ? Row(children: widgets)
          : Column(mainAxisAlignment: MainAxisAlignment.start, children: widgets),
    );
  }
}