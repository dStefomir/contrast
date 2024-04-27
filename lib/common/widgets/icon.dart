import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

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
  /// Should shimmer
  final bool shouldShimmer;
  /// Render a placeholder
  final Widget Function(BuildContext)? renderPlaceholder;

  const IconRenderer({
    Key? key,
    required this.asset,
    this.color,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.renderPlaceholder,
    this.shouldShimmer = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widget = asset.contains('.svg') ? SvgPicture.asset(
      'assets/$asset',
      width: width,
      height: height,
      placeholderBuilder: renderPlaceholder,
      fit: fit,
      color: color,
      clipBehavior: Clip.antiAlias,
    ) : FadeInImage(
      image: AssetImage('assets/$asset'),
      fit: fit,
      width: width,
      height: height,
      placeholder: const AssetImage('assets/placeholder.png'),
    );

    return shouldShimmer ? Shimmer.fromColors(
        baseColor: Colors.grey.shade400,
        highlightColor: Colors.white,
        child: widget
    ) : widget;
  }
}
