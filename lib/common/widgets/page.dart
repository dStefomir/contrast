import 'package:contrast/common/widgets/blur.dart';
import 'package:flutter/material.dart';

/// Creates a wrapper page with a background image in it.
class BackgroundPage extends StatelessWidget {
  /// Child widgets of the page
  final Widget child;
  /// Background color of the holder page
  final Color color;

  const BackgroundPage({Key? key, required this.child, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      ColoredBox(
          color: color,
          child: Stack(
            children: [
              const Blurrable(strength: 50),
              Align(
                alignment: Alignment.center,
                child: child,
              )
            ],
          )
      );
}
