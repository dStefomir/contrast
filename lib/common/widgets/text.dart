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
  /// Space between characters
  final double letterSpacing;
  /// Should the text be in italic style;
  final bool italic;
  /// Aligns the text in the widget
  final TextAlign align;
  /// Shadow
  final List<Shadow>? shadow;
  /// Font family to be used
  final String? family;

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
    this.letterSpacing = 4,
    this.italic = false,
    this.align = TextAlign.center,
    this.shadow,
    this.family
  }) : super(key: key);

  /// Renders the widget
  Widget _renderText(BuildContext context) =>
      Padding(
        padding: EdgeInsets.all(padding),
        child: Text(
            text,
            textAlign: align,
            style: TextStyle(
              fontFamily: family,
              color: color ?? Colors.black,
              overflow: clip ? TextOverflow.ellipsis : null,
              fontSize: fontSize,
              fontWeight: weight ?? FontWeight.normal,
              letterSpacing: letterSpacing,
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
