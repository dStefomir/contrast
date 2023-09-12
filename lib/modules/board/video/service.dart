import 'package:flutter/foundation.dart' as isolate;
import 'package:contrast/model/video_data.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/paged_list.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the video service
final videoBoardServiceProvider = Provider<VideoBoardService>((ref) => VideoBoardService());
/// Video page services
class VideoBoardService {
  /// Upload an video
  Future<VideoData> uploadVideo({
    required String path,
    required String comment,
    required String category,
    required int hidden,
  }) async {
    final result = await Session.proxy.post('/files/upload_video?path=$path&&comment=$comment&category=$category&hidden=$hidden',);

    return isolate.compute((response) => VideoData.fromJson(result), result);
  }

  /// Fetch the board images with selected filter
  Future<PagedList<VideoData>> getVideoBoard(int page, String selectedFilter) async {
    final result = await Session.proxy.get('/videos/available?page=$page&category=$selectedFilter');

    return isolate.compute((response) {
      final List<VideoData> data = [];
      result["content"].forEach((e) => data.add(VideoData.fromJson(e)));

      return PagedList(data, result["totalElements"], result["totalPages"]);
    }, result);
  }

  /// Fetch the board images with selected filter
  Future<PagedList<VideoData>> getHiddenVideoBoard(int page, String selectedFilter) async {
    final result = await Session.proxy.get('/videos/all?page=$page&category=$selectedFilter');

    return isolate.compute((response) {
      final List<VideoData> data = [];
      result["content"].forEach((e) => data.add(VideoData.fromJson(e)));

      return PagedList(data, result["totalElements"], result["totalPages"]);
    }, result);
  }

  /// Fetch a single image
  Future<Uint8List> getVideo(String videoPath) => isolate.compute((_) async => await Session.proxy.get('/files/video?image_path=$videoPath'), null);

  /// Edit an video
  Future<VideoData> editVideo(VideoData toEdit) async {
    final result = await Session.proxy.put('/videos/edit', data: toEdit.toJson());

    return isolate.compute((response) => VideoData.fromJson(result), result);
  }

  /// Delete an video
  Future<VideoData> deleteVideo(int id) async {
    final result = await Session.proxy.delete('/files/delete_video?id=$id');

    return isolate.compute((response) => VideoData.fromJson(result), result);
  }
}
