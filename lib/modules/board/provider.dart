import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the data view animation
final boardHeaderTabProvider = StateNotifierProvider<BoardHeaderTabNotifier, String>((ref) => BoardHeaderTabNotifier(ref: ref));
/// Notifier for handling the state footer tabs of the board
class BoardHeaderTabNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;

  BoardHeaderTabNotifier({required this.ref}) : super("all");

  /// Changes the selected tab of the board
  switchTab(String tab) {
    if (state != tab) {
      state = tab;
    }
  }
}

/// Provider for the data view animation
final boardFooterTabProvider = StateNotifierProvider<BoardFooterTabNotifier, String>((ref) => BoardFooterTabNotifier(ref: ref));
/// Notifier for handling the state footer tabs of the board
class BoardFooterTabNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;

  BoardFooterTabNotifier({required this.ref}) : super("photos");

  /// Changes the selected tab of the board
  switchTab(String tab) {
    if (state != tab) {
      state = tab;
    }
  }
}
