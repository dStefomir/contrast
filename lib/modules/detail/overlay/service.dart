import 'package:contrast/model/image_comments.dart';
import 'package:contrast/model/video_comments.dart';
import 'package:flutter/foundation.dart' as isolate;
import 'package:contrast/security/session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the comments service
final commentsServiceProvider = Provider<PhotographCommentsService>((ref) => PhotographCommentsService());
/// Photograph comments services
class PhotographCommentsService {
  /// Fetch the comments for a photograph
  Future<List<ImageCommentsData>> getPhotographComments(int photographId) async {
    final result = await Session.proxy.get('/images/comments?id=$photographId');

    return isolate.compute((response) {
      final List<ImageCommentsData> data = [];
      result.forEach((e) => data.add(ImageCommentsData.fromJson(e)));

      return data;
    }, result);
  }
  /// Post a photograph comment
  Future<ImageCommentsData> postPhotographComment(String deviceId, String deviceName, int imageId, String comment, double rating) async {
    final result = await Session.proxy.post('/images/comments?deviceId=$deviceId&deviceName=$deviceName&imageId=$imageId&comment=$comment&rating=$rating');

    return isolate.compute((response) => ImageCommentsData.fromJson(response), result);
  }
  /// Deletes a comment for a photograph
  Future<ImageCommentsData> deletePhotographComment(int id) async {
    final result = await Session.proxy.delete('/images/comments?id=$id');

    return isolate.compute((response) => ImageCommentsData.fromJson(response), result);
  }

  /// Fetch the comments for a video
  Future<List<VideoCommentsData>> getVideoComments(int videoId) async {
    final result = await Session.proxy.get('/videos/comments?id=$videoId');

    return isolate.compute((response) {
      final List<VideoCommentsData> data = [];
      result.forEach((e) => data.add(VideoCommentsData.fromJson(e)));

      return data;
    }, result);
  }
  /// Post a video comment
  Future<VideoCommentsData> postVideoComment(String deviceId, String deviceName, int videoId, String comment, double rating) async {
    final result = await Session.proxy.post('/videos/comments?deviceId=$deviceId&deviceName=$deviceName&videoId=$videoId&comment=$comment&rating=$rating');

    return isolate.compute((response) => VideoCommentsData.fromJson(response), result);
  }
  /// Deletes a comment for a video
  Future<VideoCommentsData> deleteVideoComment(int id) async {
    final result = await Session.proxy.delete('/videos/comments?id=$id');

    return isolate.compute((response) => VideoCommentsData.fromJson(response), result);
  }
}