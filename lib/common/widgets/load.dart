import 'package:flutter/material.dart';

/// Circle loading indicator widget
class LoadingIndicator extends StatelessWidget {
  /// Color of the indicator
  final Color color;

  const LoadingIndicator({Key? key, this.color = Colors.grey}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(color: color));
}
