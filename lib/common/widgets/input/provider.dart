import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for text obscure function
final textObscureProvider = StateNotifierProvider.family<TextObscureNotifier, bool, bool>((ref, value) => TextObscureNotifier(shouldObscure: value));
/// Notifier for text obscure function
class TextObscureNotifier extends StateNotifier<bool> {
  /// Should obscure the widget
  final bool shouldObscure;

  TextObscureNotifier({required this.shouldObscure}) : super(shouldObscure);

  /// Sets the obscure value
  void onObscure(bool hover) => state = hover;
}
