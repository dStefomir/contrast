import 'package:contrast/modules/board/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Closes an overlay if its opened
void closeOverlayIfOpened(WidgetRef ref, String key) {
  if (ref.read(overlayVisibilityProvider(Key(key))) != null) {
    ref.read(overlayVisibilityProvider(Key(key)).notifier).setOverlayVisibility(false);
  }
}