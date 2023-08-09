import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:contrast/modules/board/video/service.dart';
import 'package:flutter/material.dart';
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

/// Provider for deleting a photograph
final deleteImageProvider = StateNotifierProvider<DeleteImageNotifier, ImageData?>((ref) => DeleteImageNotifier(ref: ref));
/// Notifier for deleting a photograph
class DeleteImageNotifier extends StateNotifier<ImageData?> {
  /// Reference
  final Ref ref;

  DeleteImageNotifier({required this.ref}) : super(null);

  /// Sets a selected photograph for deletion
  void setDeleteImage(ImageData? image) => state = image;
}

/// Provider for deleting a video
final deleteVideoProvider = StateNotifierProvider<DeleteVideoNotifier, VideoData?>((ref) => DeleteVideoNotifier(ref: ref));
/// Notifier for deleting a video
class DeleteVideoNotifier extends StateNotifier<VideoData?> {
  /// Reference
  final Ref ref;

  DeleteVideoNotifier({required this.ref}) : super(null);

  /// Sets a selected video for deletion
  void setDeleteVideo(VideoData? video) => state = video;
}