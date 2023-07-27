import 'package:flutter/material.dart';

/// Extension for a general widget
extension HoverExtension on Widget {
  /// Zoom out effect for a photo
  Widget get translateOnPhotoHover => TranslateOnHover(child: this);

  /// Zoom out effect for video/thumbnail
  Widget get translateOnVideoHover => TranslateOnHover(maxScale: 1.5,child: this,);
}

/// Widget which performs the zoom out effect for the extension
class TranslateOnHover extends StatefulWidget {
  /// Child widget
  final Widget child;
  /// Max zoom out effect
  final double? maxScale;

  const TranslateOnHover({Key? key, required this.child, this.maxScale}) : super(key: key);

  @override
  _TranslateOnHoverState createState() => _TranslateOnHoverState();
}

class _TranslateOnHoverState extends State<TranslateOnHover> {
  /// Zoom level
  late double scale;

  @override
  void initState() {
    scale = 1.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (e) => _mouseEnter(true),
    onExit: (e) => _mouseEnter(false),
    child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 1.0, end: scale),
        builder: (BuildContext context, double value, _) => Transform.scale(scale: value, child: widget.child)
    ),
  );

  /// What happens when the mouse gets in the widget constraints
  void _mouseEnter(bool hover) =>
    setState(() {
      if (hover) {
        scale = widget.maxScale ?? 1.03;
      } else {
        scale = 1.0;
      }
    });
}