import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/hover_provider.dart';
import 'package:contrast/common/widgets/overlay.dart';
import 'package:contrast/common/widgets/photograph.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Widget which shows the thumbnail of video
class ContrastVideo extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// Path of the video
  final String videoPath;
  /// Constraints of the parent page
  final BoxConstraints constraints;
  /// What happens when the widgets is clicked
  final Function onClick;
  /// What happens when the user clicks the redirect button
  final Function? onRedirect;
  /// Is the widget disabled or not
  final bool disabled;

  const ContrastVideo({
    required this.widgetKey,
    required this.videoPath,
    required this.constraints,
    required this.onClick,
    this.onRedirect,
    this.disabled = false,
  }) : super(key: widgetKey);

  List<Widget> renderFilmLikeWidget() {
    final List<Widget> widgets = [];
    const int whiteBoxes = 5;
    double whiteBoxWidth = constraints.maxWidth / 20;

    for (int i = 0; i < whiteBoxes - 1; i++) {
      widgets.add(const Spacer());
      widgets.add(
          Container(
            width: whiteBoxWidth,
            height: constraints.maxHeight / 20,
            color: Colors.white.withOpacity(0.9),
          )
      );
      widgets.add(const Spacer());
    }

    return widgets;
  }

  /// Shows the popup overlay
  OverlayEntry _createPopupDialog(BuildContext context, PhotographBoardService serviceProvider) =>
      OverlayEntry(
          builder: (_) => BlurryContainer(
            child: AnimatedDialog(
                width: constraints.maxWidth + 150,
                height: constraints.maxHeight + 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _renderVideoThumbnail(context, serviceProvider),
                  ],
                ),
            ),
          )
      );

  /// Renders the video widget
  Widget _renderVideoWidget(BuildContext context, PhotographBoardService serviceProvider, bool isHovering) => Stack(
    alignment: Alignment.center,
    children: [
      _renderVideoThumbnail(context, serviceProvider),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: constraints.maxHeight / 8),
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight / 9.5,
            color: isHovering ? Colors.black : const Color.fromRGBO(67, 66, 66, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: renderFilmLikeWidget(),
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: constraints.maxHeight / 8),
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight / 9.5,
            color: isHovering ? Colors.black : const Color.fromRGBO(67, 66, 66, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: renderFilmLikeWidget(),
            ),
          ),
        ),
      ),
      if (!disabled) Visibility(
        visible: isHovering,
        child: SizedBox(
          height: double.infinity,
          child: Center(
              child: ShadowWidget(
                blurRadius: 20,
                shouldHaveBorderRadius: true,
                child: Icon(Icons.play_arrow,
                    color: Colors.white,
                    size: constraints.maxHeight / 4
                ),
              )
          ),
        ).translateOnVideoHover,
      ),
      if (!disabled && isHovering && onRedirect != null)
        Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: constraints.maxHeight / 4.45),
              child: RedirectButton(
                widgetKey: Key('$widgetKey/redirect'),
                constraints: constraints,
                onRedirect: onRedirect!,
                height: constraints.maxHeight / 7,
              ),
            )
        )
    ],
  );

  /// Renders the video thumbnail
  Widget _renderVideoThumbnail(BuildContext context, PhotographBoardService serviceProvider) => ContrastPhotograph(
    widgetKey: Key('${widgetKey.toString()}_photograph'),
    fetch: (path) => serviceProvider.getCompressedPhotograph(context, videoPath, true),
    constraints: constraints,
    image: ImageData(path: videoPath),
    quality: FilterQuality.high,
    borderColor: Colors.transparent,
    fit: BoxFit.contain,
    compressed: false,
    isThumbnail: true,
    height: double.infinity,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHovering = ref.watch(hoverProvider(widgetKey));
    final serviceProvider = ref.read(photographyBoardServiceProvider);
    OverlayEntry? popupDialog;

    return Material(
        color: Colors.transparent,
        child: !disabled ? InkWell(
          hoverColor: Colors.transparent,
          onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
          onTap: () {},
          child: GestureDetector(
              onTap: () => onClick(),
              onLongPressStart: (_) {
                if (!isHovering && (useMobileLayoutOriented(context) && useMobileLayout(context))) {
                  if (popupDialog == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      popupDialog = _createPopupDialog(context, serviceProvider);
                      Overlay.of(context).insert(popupDialog!);
                    });
                  }
                } else if (!isHovering && !(useMobileLayoutOriented(context) && useMobileLayout(context))) {
                  ref.read(hoverProvider(widgetKey).notifier).onHover(true);
                }
              },
              onLongPressEnd: (details) {
                if ((useMobileLayoutOriented(context) && useMobileLayout(context))) {
                  popupDialog?.remove();
                  popupDialog = null;
                } else {
                  ref.read(hoverProvider(widgetKey).notifier).onHover(false);
                }
              },
              child: _renderVideoWidget(context, serviceProvider, isHovering)
          )
        ) : _renderVideoWidget(context, serviceProvider, isHovering)
    );
  }
}
