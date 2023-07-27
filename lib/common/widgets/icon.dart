import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Svg widget
class IconRenderer extends StatelessWidget {
  /// Asset for the svg widget
  final String asset;
  /// Color of the svg
  final Color? color;
  /// Fit concept for the svg
  final BoxFit fit;
  /// Width of the svg
  final double? width;
  /// Height of the svg
  final double? height;

  const IconRenderer({
    Key? key,
    required this.asset,
    this.color,
    this.fit = BoxFit.contain,
    this.width,
    this.height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      asset.contains('.svg') ? SvgPicture.asset(
        'assets/$asset',
        width: width,
        height: height,
        fit: fit,
        color: color,
        clipBehavior: Clip.antiAlias,
      ) : Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/$asset',
            fit: width != null ? BoxFit.fitHeight : BoxFit.fitWidth,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.low,
          ),
          Container(color: Colors.white.withOpacity(0.95),),
        ],
      );
}
