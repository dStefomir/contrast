import 'package:contrast/model/image_comments.dart';
import 'package:flutter/foundation.dart' as isolate;
import 'package:contrast/security/session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the photograph comments service
final photographCommentsServiceProvider = Provider<PhotographCommentsService>((ref) => PhotographCommentsService());
/// Photograph comments services
class PhotographCommentsService {
  /// Fetch the comments for a photograph
  Future<List<ImageCommentsData>> getComments(int photographId) async {
    final result = await Session.proxy.get('/images/comments?id=$photographId');

    return isolate.compute((response) {
      final List<ImageCommentsData> data = [];
      result.forEach((e) => data.add(ImageCommentsData.fromJson(e)));

      return data;
    }, result);
  }
  /// Fetch the comments for a photograph
  Future<ImageCommentsData> postComment(String deviceName, int imageId, String comment, double rating) async {
    final result = await Session.proxy.post('/images/comments?deviceName=$deviceName&imageId=$imageId&comment=$comment&rating=$rating');

    return isolate.compute((response) => ImageCommentsData.fromJson(response), result);
  }
  /// Deletes a comment for a photograph
  Future<ImageCommentsData> deleteComment(int id) async {
    final result = await Session.proxy.delete('/images/comments?id=$id');

    return isolate.compute((response) => ImageCommentsData.fromJson(response), result);
  }
}