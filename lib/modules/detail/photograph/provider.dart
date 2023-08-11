import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetch Board api provider
final fetchBoardProvider = FutureProvider.autoDispose<List<ImageData>>((ref) async {
  final selectedFilterProvider = ref.read(boardHeaderTabProvider);
  final provider = ref.watch(photographyBoardServiceProvider);
  final List<ImageData> photographs = await provider.getImageBoardNonFiltered(selectedFilterProvider);

  return photographs;
});
/// Provider for current index of the photograph
final photographIndexProvider = StateNotifierProvider.family.autoDispose<PhotographIndexNotifier, int, int>((ref, value) => PhotographIndexNotifier(ref: ref, index: value));
/// Notifier for handling the current index of the photograph
class PhotographIndexNotifier extends StateNotifier<int> {
  /// Reference
  final Ref ref;
  /// Current photograph index
  final int index;

  PhotographIndexNotifier({required this.ref, required this.index}) : super(index);

  /// Sets the current index of the photograph
  setCurrentPhotographIndex(int index) => state = index;
}

/// Provider for photograph detail asset
final photographDetailAssetProvider = StateNotifierProvider.autoDispose<PhotographDetailAssetNotifier, String>((ref) => PhotographDetailAssetNotifier(ref: ref));
/// Notifier for photograph detail asset
class PhotographDetailAssetNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;

  PhotographDetailAssetNotifier({required this.ref}) : super('map.svg');

  /// Sets the current detail asset
  setDetailAsset(String asset) => state = asset;
}

/// Provider for the photograph title visibility
final photographTitleVisibilityProvider = StateNotifierProvider.autoDispose<PhotographTitleVisibilityNotifier, bool>((ref) => PhotographTitleVisibilityNotifier(ref: ref));
/// Notifier for photograph title visibility
class PhotographTitleVisibilityNotifier extends StateNotifier<bool> {
  /// Reference
  final Ref ref;

  PhotographTitleVisibilityNotifier({required this.ref}) : super(true);

  /// Sets the visibility of the photograph title
  setVisibility(bool visibility) => state = visibility;
}

/// Provider for the rendering widget on top in a stack
final widgetOnTopProvider = StateNotifierProvider.autoDispose<WidgetOnTopNotifier, String>((ref) => WidgetOnTopNotifier(ref: ref));
/// Notifier for the rendering widget on top in a stack
class WidgetOnTopNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;

  WidgetOnTopNotifier({required this.ref}) : super('PHOTOGRAPH');

  /// Sets the widget to be on top in a stack
  setWidgetOnTop(String widget) => state = widget;
}

/// Provider for the rendering the opacity for the photograph
final photographOpacityProvider = StateNotifierProvider.autoDispose<PhotographOpacityNotifier, double>((ref) => PhotographOpacityNotifier(ref: ref));
/// Notifier for the rendering the opacity for the photograph
class PhotographOpacityNotifier extends StateNotifier<double> {
  /// Reference
  final Ref ref;

  PhotographOpacityNotifier({required this.ref}) : super(0);

  /// Sets the opacity for the photograph
  setOpacity(double opacity) => state = opacity;
}