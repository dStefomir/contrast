import 'package:flutter/material.dart';

/// Renders a border around a child widget
class BorderWidget extends StatelessWidget {
  /// Border color
  final Color color;
  /// Width of the border
  final double width;
  /// Radius of the border
  final double radius;
  /// Should the border be applied only at the top
  final bool onlyTop;
  /// Child widget
  final Widget child;

  const BorderWidget({super.key, required this.child, this.color = Colors.black, this.width = 5, this.radius = 0, this.onlyTop = true});

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        border: onlyTop ? Border(
          top: BorderSide(
              color: color,
              width: width
          )
        ) : Border.all(
            color: color,
            width: width
        )
      ),
    child: child,
  );
}