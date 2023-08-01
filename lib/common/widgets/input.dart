import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Text input widget
class SimpleInput extends StatefulHookConsumerWidget {
  /// Key of the widget
  final Key widgetKey;
  /// Simple input controller`s text
  final String controllerText;
  /// Label text for the text input
  final String labelText;
  /// Text hint for the text input
  final String hint;
  /// Prefix icon widget
  final IconData? prefixIcon;
  /// Is the input widget a password field
  final bool password;
  /// Called when text changes
  final String Function(String) onChange;
  /// Lines allowed in the text input
  final int maxLines;
  /// Validator function for the text input
  final String? Function(String?)? validator;

  const SimpleInput({
    required this.widgetKey,
    required this.onChange,
    this.controllerText = '',
    this.labelText = '',
    this.hint = '',
    this.prefixIcon,
    this.password = false,
    this.maxLines = 1,
    this.validator
  }) : super(key: widgetKey);

  @override
  ConsumerState createState() => SimpleInputState();
}

class SimpleInputState extends ConsumerState<SimpleInput> {
  /// Controller for the simple input
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.controllerText);
    _controller.addListener(() => widget.onChange(_controller.text));
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(() => widget.onChange(_controller.text));
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
      controller: _controller,
      autofocus: false,
      obscureText: widget.password,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.prefixIcon),
        labelText: widget.labelText,
        hintText: widget.hint
      ),
      validator: widget.validator
  );
}