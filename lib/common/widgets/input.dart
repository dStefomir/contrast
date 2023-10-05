import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Text input widget
class SimpleInput extends StatefulHookConsumerWidget {
  /// Key of the widget
  final Key widgetKey;
  /// Simple input controller
  final TextEditingController? controller;
  /// Simple input controller`s text
  final String? controllerText;
  /// Label text for the text input
  final String labelText;
  /// Text hint for the text input
  final String hint;
  /// Prefix icon widget
  final IconData? prefixIcon;
  /// Sufix widget
  final Widget? suffixWidget;
  /// Is the input widget a password field
  final bool password;
  /// Called when text changes
  final String Function(String) onChange;
  /// Lines allowed in the text input
  final int maxLines;
  /// Color of the background of the simple input field
  final Color backgroundColor;
  /// Focus node for switching focus
  final FocusNode? focusNode;
  /// Is the widget enabled or not
  final bool enabled;
  /// Validator function for the text input
  final String? Function(String?)? validator;

  const SimpleInput({
    required this.widgetKey,
    required this.onChange,
    this.controller,
    this.controllerText,
    this.labelText = '',
    this.hint = '',
    this.prefixIcon,
    this.suffixWidget,
    this.password = false,
    this.maxLines = 1,
    this.backgroundColor = Colors.white,
    this.focusNode,
    this.enabled = true,
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
    if(widget.controller == null) {
      _controller = TextEditingController(text: widget.controllerText ?? '');
      _controller.addListener(() => widget.onChange(_controller.text));
    }
    super.initState();
  }

  @override
  void dispose() {
    if(widget.controller == null) {
      _controller.removeListener(() => widget.onChange(_controller.text));
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
      controller: widget.controller ?? _controller,
      obscureText: widget.password,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.prefixIcon, color: Colors.black,),
        suffixIcon: widget.suffixWidget,
        labelText: widget.labelText,
        hintText: widget.hint,
        fillColor: widget.backgroundColor
      ),
      validator: widget.validator
  );
}