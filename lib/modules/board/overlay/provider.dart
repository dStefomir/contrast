import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/video/service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for deleting entries
final deleteEntriesProvider = StateNotifierProvider<FileServiceNotifier, AsyncValue<String>>((ref) => FileServiceNotifier(ref: ref));
/// Notifier for deleting entries
class FileServiceNotifier extends StateNotifier<AsyncValue<String>> {
  /// Reference
  final Ref ref;

  FileServiceNotifier({required this.ref}) : super(const AsyncValue.loading());

  /// Deletes a photograph
  Future<ImageData> deletePhotograph(ImageData data) async {
    final serviceProvider = ref.watch(photographyBoardServiceProvider);
    final ImageData result = await serviceProvider.deleteImage(data.id!);
    state = const AsyncValue.data('OK');

    return result;
  }

  /// Deletes a video
  Future<VideoData> deleteVideo(VideoData data) async {
    final serviceProvider = ref.watch(videoBoardServiceProvider);
    final VideoData result = await serviceProvider.deleteVideo(data.id!);
    state = const AsyncValue.data("OK");

    return result;
  }
}