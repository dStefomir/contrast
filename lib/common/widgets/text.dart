import 'package:flutter/material.dart';

/// Styled text widget
class StyledText extends StatelessWidget {
  /// Text as string
  final String text;
  /// Color of the text
  final Color? color;
  /// Font size
  final double? fontSize;
  /// Text decoration weight
  final FontWeight? weight;
  /// Text decoration
  final TextDecoration? decoration;
  /// Should the widget contain a shadow
  final bool useShadow;
  /// Should the widget clip the text or not
  final bool clip;
  /// Padding applied to the text widget
  final double padding;
  /// Should the text be in italic style;
  final bool italic;
  /// Shadow
  final List<Shadow>? shadow;

  const StyledText({
    Key? key,
    required this.text,
    this.fontSize = 20,
    this.color,
    this.weight,
    this.decoration,
    this.useShadow = false,
    this.clip = true,
    this.padding = 15,
    this.italic = false,
    this.shadow
  }) : super(key: key);

  /// Renders the widget
  Widget _renderText(BuildContext context) =>
      Padding(
        padding: EdgeInsets.all(padding),
        child: Text(
            text,
            textAlign: clip ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: color ?? Colors.black,
              overflow: clip ? TextOverflow.ellipsis : null,
              fontSize: fontSize,
              fontWeight: weight ?? FontWeight.normal,
              letterSpacing: 4,
              decoration: decoration ?? TextDecoration.none,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              shadows: useShadow ? shadow ??
                  const <Shadow>[
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 8.0,
                      color: Colors.black,
                    ),
                  ] : null
            )
        ),
    );

  @override
  Widget build(BuildContext context) => _renderText(context);
}
