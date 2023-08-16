import 'package:flutter/material.dart';

/// Circle loading indicator widget
class LoadingIndicator extends StatelessWidget {
  /// Color of the indicator
  final Color color;
  /// Widget width
  final double width;
  /// Widget height
  final double height;
  /// Widget stroke width
  final double stroke;

  const LoadingIndicator({Key? key, this.color = Colors.grey, this.width = 40, this.height = 40, this.stroke = 4}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Center(
          child:
          SizedBox(
              width: width,
              height: height,
              child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: stroke
              )
          )
      );
}
