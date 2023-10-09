import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/hover_provider.dart';
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

  /// Renders the video widget
  Widget _renderVideoWidget(BuildContext context, WidgetRef ref, PhotographBoardService serviceProvider, bool isHovering) => Stack(
    alignment: Alignment.center,
    children: [
      ContrastPhotograph(
        widgetKey: Key('${widgetKey.toString()}/photograph'),
        fetch: (path) => serviceProvider.getCompressedPhotograph(context, videoPath, true),
        constraints: constraints,
        image: ImageData(path: videoPath),
        quality: FilterQuality.high,
        borderColor: Colors.transparent,
        fit: BoxFit.contain,
        compressed: false,
        isThumbnail: true,
        height: double.infinity,
      ),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: constraints.maxHeight / 8),
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight / 10,
            color: isHovering ? Colors.black : Colors.black54,
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
            height: constraints.maxHeight / 10,
            color: isHovering ? Colors.black : Colors.black54,
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
      if (!disabled && isHovering && onRedirect != null && getRunningPlatform(context) == 'DESKTOP')
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHovering = ref.watch(hoverProvider(widgetKey));
    final serviceProvider = ref.read(photographyBoardServiceProvider);

    return Material(
        color: Colors.transparent,
        child: !disabled ? InkWell(
          hoverColor: Colors.transparent,
          onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
          onTap: () {},
          child: GestureDetector(
              onTap: () => onClick(),
              onLongPress: () => ref.read(hoverProvider(widgetKey).notifier).onHover(true),
              onLongPressEnd: (details) => ref.read(hoverProvider(widgetKey).notifier).onHover(false),
              child: _renderVideoWidget(context, ref, serviceProvider, isHovering)
          )
        ) : _renderVideoWidget(context, ref, serviceProvider, isHovering)
    );
  }
}
