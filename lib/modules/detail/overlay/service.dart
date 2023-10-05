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
  Future<List<ImageCommentsData>> getPhotographComments(int photographId, bool isAdmin) async {
    final String endPointUrl = isAdmin ? '/images/comments/all?id=$photographId' : '/images/comments?id=$photographId';
    final result = await Session.proxy.get(endPointUrl);

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
  /// Approves a photograph comment
  Future<ImageCommentsData> approvePhotographComment(int id) async {
    final result = await Session.proxy.put('/images/comments?id=$id');

    return isolate.compute((response) => ImageCommentsData.fromJson(response), result);
  }
  /// Deletes a comment for a photograph
  Future<ImageCommentsData> deletePhotographComment(int id, String deviceId) async {
    final result = await Session.proxy.delete('/images/comments?id=$id&deviceId=$deviceId');

    return isolate.compute((response) => ImageCommentsData.fromJson(response), result);
  }
  /// Deletes a comment for a photograph as admin
  Future<ImageCommentsData> deletePhotographCommentAsAdmin(int id) async {
    final result = await Session.proxy.delete('/images/comments?id=$id');

    return isolate.compute((response) => ImageCommentsData.fromJson(response), result);
  }

  /// Fetch the comments for a video
  Future<List<VideoCommentsData>> getVideoComments(int videoId, bool isAdmin) async {
    final String endPointUrl = isAdmin ? '/videos/comments/all?id=$videoId' : '/videos/comments?id=$videoId';
    final result = await Session.proxy.get(endPointUrl);

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
  /// Approves a video comment
  Future<VideoCommentsData> approveVideoComment(int id) async {
    final result = await Session.proxy.put('/videos/comments?id=$id');

    return isolate.compute((response) => VideoCommentsData.fromJson(response), result);
  }
  /// Deletes a comment for a video
  Future<VideoCommentsData> deleteVideoComment(int id, String deviceId) async {
    final result = await Session.proxy.delete('/videos/comments?id=$id&deviceId=$deviceId');

    return isolate.compute((response) => VideoCommentsData.fromJson(response), result);
  }
  /// Deletes a comment for a video as admin
  Future<VideoCommentsData> deleteVideoCommentAsAdmin(int id) async {
    final result = await Session.proxy.delete('/videos/comments?id=$id');

    return isolate.compute((response) => VideoCommentsData.fromJson(response), result);
  }
}