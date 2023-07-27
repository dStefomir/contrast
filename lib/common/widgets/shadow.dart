import 'package:flutter/material.dart';

/// Widget which renders a shadow for its child
class ShadowWidget extends StatelessWidget {
  /// Child widget
  final Widget child;
  /// Offset of the shadow
  final Offset offset;
  /// Should the shadow have a border radius
  final bool shouldHaveBorderRadius;
  /// What the blur radius should be
  final double blurRadius;
  /// What the shadow size should be
  final double shadowSize;
  /// What the shadow color should be
  final Color shadowColor;

  const ShadowWidget({
    Key? key,
    required this.child,
    this.offset = const Offset(0, 3),
    this.shouldHaveBorderRadius = false,
    this.blurRadius = 5,
    this.shadowSize = 1,
    this.shadowColor = Colors.black54
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Container(
        decoration: BoxDecoration(
          borderRadius: shouldHaveBorderRadius ? const BorderRadius.all(Radius.circular(25.0)) : null,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: shadowSize,
              blurRadius: blurRadius,
              offset: offset,
            ),
          ],
        ),
        child: child,
      );
}