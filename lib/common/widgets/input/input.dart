import 'package:contrast/common/widgets/input/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Text input widget
class SimpleInput extends HookConsumerWidget {
  final String controllerText;
  /// Label text for the text input
  final String labelText;
  /// Text hint for the text input
  final String hint;
  /// Prefix icon to be shown in the text input
  final String? prefixIconAsset;
  /// Prefix icon widget
  final IconData? prefixIcon;
  /// Is input from the user required in the text input
  final bool isRequired;
  /// Is the input widget a password field
  final bool password;
  /// Called when text changes
  final String Function(String) onChange;
  /// Lines allowed in the text input
  final int maxLines;
  /// Validator function for the text input
  final String? Function(String?)? validator;

  const SimpleInput({
    Key? key,
    required this.onChange,
    this.controllerText = '',
    this.labelText = '',
    this.hint = '',
    this.prefixIconAsset,
    this.prefixIcon,
    this.isRequired = false,
    this.password = false,
    this.maxLines = 1,
    this.validator
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = useTextEditingController();
    controller.text = controllerText;
    final bool shouldObscure = ref.watch(textObscureProvider(password));
    controller.addListener(() => onChange(controller.text));

    return TextFormField(
        controller: controller,
        obscureText: shouldObscure,
        maxLines: maxLines,
        decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon),
            labelText: labelText,
            hintText: hint,
            suffixIcon: password
                ? IconButton(
                    onPressed: () => ref.read(textObscureProvider(password).notifier).onObscure(!shouldObscure),
                    icon: const Icon(Icons.visibility)
            )
                : null
        ),
        validator: validator
    );
  }
}