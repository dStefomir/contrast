import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetch Board api provider
final fetchBoardProvider = FutureProvider.autoDispose<List<ImageData>>((ref) async {
  final selectedFilterProvider = ref.read(boardHeaderTabProvider);
  final provider = ref.watch(photographyBoardServiceProvider);
  try {
    return await provider.getImageBoardNonFiltered(selectedFilterProvider);
  } catch (e) {
    return [];
  }
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

/// Provider for trigger the music play
final musicTriggerProvider = StateNotifierProvider.autoDispose<MusicTriggerNotifier, bool>((ref) => MusicTriggerNotifier(ref: ref));
/// Notifier for trigger the music play
class MusicTriggerNotifier extends StateNotifier<bool> {
  /// Reference
  final Ref ref;

  MusicTriggerNotifier({required this.ref}) : super(false);

  /// Sets the music play state
  setPlay(bool play) => state = play;
}