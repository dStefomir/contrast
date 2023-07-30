import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the data view animation
final corePageProvider = StateNotifierProvider.family<CookieOverlayNotifier, bool, bool>((ref, value) => CookieOverlayNotifier(ref: ref, shouldShowCookieOverlay: value));
/// Notifier for handling the state footer tabs of the board
class CookieOverlayNotifier extends StateNotifier<bool> {
  /// Reference
  final Ref ref;
  /// Should show cookie overlay
  final bool shouldShowCookieOverlay;

  CookieOverlayNotifier({required this.ref, required this.shouldShowCookieOverlay}) : super(shouldShowCookieOverlay);

  /// Sets the condition of which the cookie overlay is been rendered
  setCookieOverlayDisplay(bool value) => state = !value;
}