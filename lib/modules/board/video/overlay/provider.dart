import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/video/service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the loading state
final loadingProvider = StateNotifierProvider<LoadingStateNotifier, bool>((ref) => LoadingStateNotifier(ref: ref));
/// Notifier for the loading state
class LoadingStateNotifier extends StateNotifier<bool> {
  /// Reference
  final Ref ref;

  LoadingStateNotifier({required this.ref}) : super(false);

  /// sets the loading state
  setLoading(bool value) => state = value;
}

/// Provider for the url of the video
final videoUrlProvider = StateNotifierProvider<VideoUrlNotifier, String>((ref) => VideoUrlNotifier(ref: ref));
/// Notifier for handling the video comment
class VideoUrlNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;

  VideoUrlNotifier({required this.ref}) : super("");

  /// Sets the video url
  setUrl(String value) => state = value;
}

/// Provider for the comment of the video
final commentProvider = StateNotifierProvider<VideoCommentNotifier, String>((ref) => VideoCommentNotifier(ref: ref));
/// Notifier for handling the video comment
class VideoCommentNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;

  VideoCommentNotifier({required this.ref}) : super("");

  /// Sets the video comment
  setComment(String value) => state = value;
}

/// Provider for CRUD video functions
final uploadVideoProvider = StateNotifierProvider<VideoServiceNotifier, AsyncValue<String>>((ref) => VideoServiceNotifier(ref: ref));
/// Notifier for posting a file to an api
class VideoServiceNotifier extends StateNotifier<AsyncValue<String>> {
  /// Reference
  final Ref ref;

  VideoServiceNotifier({required this.ref}) : super(const AsyncValue.loading());

  /// Edits a video
  Future<VideoData> editVideo(VideoData data) async {
    final String url = ref.read(videoUrlProvider);
    final String comment = ref.read(commentProvider);
    final serviceProvider = ref.watch(videoBoardServiceProvider);
    final updatedVideo = await serviceProvider.editVideo(
        VideoData(
            id: data.id,
            path: url,
            category: 'other',
            comment: comment,
            hidden: 0
        )
    );
    state = const AsyncValue.data('OK');

    return updatedVideo;
  }

  /// Posts a video
  Future<VideoData> postVideo() async {
    final String url = ref.read(videoUrlProvider);
    final String comment = ref.read(commentProvider);
    final serviceProvider = ref.watch(videoBoardServiceProvider);
    final video = await serviceProvider.uploadVideo(path: url, comment: comment, category: 'other', hidden: 0);
    state = const AsyncValue.data('OK');

    return video;
  }
}