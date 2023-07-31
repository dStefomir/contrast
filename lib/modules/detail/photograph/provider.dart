import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

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

/// Provider for scale function of the photograph
final photographScaleProvider = StateNotifierProvider.autoDispose<PhotographScaleNotifier, PhotoViewScaleStateController>((ref) {
  ref.keepAlive();
  final PhotoViewScaleStateController controller = PhotoViewScaleStateController();
  ref.onDispose(() => controller.dispose());

  return PhotographScaleNotifier(ref: ref, controller: controller);
});
/// Notifier for handling photograph scale
class PhotographScaleNotifier extends StateNotifier<PhotoViewScaleStateController> {
  /// Reference
  final Ref ref;

  /// Scale controller
  final PhotoViewScaleStateController controller;

  PhotographScaleNotifier({required this.ref, required this.controller}) : super(controller);
}

/// Provider for scale function of the photograph
final photographDetailAssetProvider = StateNotifierProvider.autoDispose<PhotographDetailAssetNotifier, String>((ref) => PhotographDetailAssetNotifier(ref: ref));
/// Notifier for handling photograph scale
class PhotographDetailAssetNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;

  PhotographDetailAssetNotifier({required this.ref}) : super('map.svg');

  /// Sets the current detail asset
  setDetailAsset(String asset) => state = asset;
}
