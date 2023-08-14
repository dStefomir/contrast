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

  const ContrastVideo({
    required this.widgetKey,
    required this.videoPath,
    required this.constraints,
    required this.onClick,
    this.onRedirect
  }) : super(key: widgetKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHovering = ref.watch(hoverProvider(widgetKey));
    final serviceProvider = ref.read(photographyBoardServiceProvider);

    return Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Colors.black,
          onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
          onTap: () {},
          child: GestureDetector(
            onTap: () => onClick(),
            onLongPress: () => ref.read(hoverProvider(widgetKey).notifier).onHover(true),
            onLongPressEnd: (details) => ref.read(hoverProvider(widgetKey).notifier).onHover(false),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ContrastPhotograph(
                    widgetKey: Key('${widgetKey.toString()}/photograph'),
                    fetch: (path) => serviceProvider.getCompressedPhotograph(context, videoPath, true),
                    image: ImageData(path: videoPath),
                    quality: FilterQuality.high,
                    borderColor: Colors.black,
                    compressed: false,
                    isThumbnail: true,
                    height: double.infinity,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Visibility(
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
                ),
                isHovering && onRedirect != null && getRunningPlatform(context) == 'DESKTOP'
                    ? Align(
                    alignment: Alignment.topRight,
                    child: RedirectButton(
                      widgetKey: Key('$widgetKey/redirect'),
                      constraints: constraints,
                      onRedirect: onRedirect!,
                      height: constraints.maxHeight / 6.1,
                    )
                ) : Container()
              ],
            ),
          ),
        )
    );
  }
}
