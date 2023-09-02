import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

/// Widget witch shows a tooltip
class StyledTooltip extends StatelessWidget {
  /// Text of the tooltip
  final String text;
  /// Child widget
  final Widget child;
  /// Where the tooltip should point to
  final AxisDirection pointingPosition;

  const StyledTooltip({super.key, required this.text, required this.child, this.pointingPosition = AxisDirection.down});

  @override
  Widget build(BuildContext context) => JustTheTooltip(
      content: StyledText(
        text: text,
        fontSize: 12,
        padding: 5,
        letterSpacing: 2,
        weight: FontWeight.bold,
      ),
      elevation: 1,
      offset: 2,
      borderRadius: BorderRadius.zero,
      fadeInDuration: const Duration(milliseconds:  300),
      fadeOutDuration: const Duration(milliseconds:  300),
      preferredDirection: pointingPosition,
      child: child
  );
}