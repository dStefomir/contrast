import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for hover animation of buttons
final hoverProvider = StateNotifierProvider.family<HoverNotifier, bool, Key>((ref, key) => HoverNotifier());
/// Notifier for hover animation of buttons
class HoverNotifier extends StateNotifier<bool> {
  HoverNotifier() : super(false);

  /// Sets the hover value
  void onHover(bool hover) => state = hover;
}
