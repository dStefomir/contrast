import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// Renders a blurrable widget
class Blurrable extends StatelessWidget {
  /// Child widget
  final Widget? child;
  /// Blur strength
  final double strength;

  const Blurrable({this.child, this.strength = 3, super.key});

  @override
  Widget build(BuildContext context) => BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: strength,
        sigmaY: strength,
      ),
      child: child ?? const SizedBox.shrink()
  );
}