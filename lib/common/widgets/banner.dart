import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gif/flutter_gif.dart';

/// This widget renders a banner photo or video
class BannerWidget extends StatefulHookConsumerWidget {
  /// Banner
  final String banner;
  /// Banner quotes
  final String quote;

  const BannerWidget({
    super.key,
    required this.banner,
    this.quote = '',
  });

  @override
  ConsumerState createState() => BannerWidgetState();
}

class BannerWidgetState extends ConsumerState<BannerWidget> with TickerProviderStateMixin {
  /// Controller for the giff header of the data view
  FlutterGifController? _videoBoardGiffController;

  @override
  void initState() {
    _videoBoardGiffController = widget.banner.contains('.gif')
        ? FlutterGifController(vsync: this)
        : null;
    super.initState();
  }

  @override
  void dispose() {
    if (_videoBoardGiffController != null) {
      try {
        _videoBoardGiffController!.dispose();
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banner.contains('.gif')) {
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => _videoBoardGiffController!.repeat(
                  min: 1,
                  max: 299,
                  period: const Duration(seconds: 10)
              )
      );
    }

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        widget.banner.contains('.gif') ?
        GifImage(
          controller: _videoBoardGiffController!,
          fit: BoxFit.cover,
          image: AssetImage("assets/${widget.banner}"),
        ) :
        IconRenderer(asset: widget.banner, fit: BoxFit.cover),
        Align(
          alignment: Alignment.center,
          child: FadeAnimation(
            duration: const Duration(milliseconds: 2000),
            start: 1,
            end: 0,
            child: StyledText(
              maxLines: 1,
              text: widget.quote,
              color: Colors.white,
              useShadow: true,
              align: TextAlign.start,
              letterSpacing: 5,
              fontSize: 25,
              italic: true,
              clip: true,
            ),
          ),
        )
      ],
    );
  }
}