import 'package:flutter/foundation.dart' as isolate;
import 'package:contrast/model/image_data.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/device.dart';
import 'package:contrast/utils/paged_list.dart';
import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the photograph service
final photographyBoardServiceProvider = Provider<PhotographBoardService>((ref) => PhotographBoardService());
/// Board page services
class PhotographBoardService {
  /// Fetch the board images with selected filter
  Future<PagedList<ImageWrapper>> getImageBoard(int page, String selectedFilter) async {
    final result = await Session.proxy.get('/images/all?page=$page&category=$selectedFilter');

    return isolate.compute((response) {
      final List<ImageWrapper> data = [];
      result["content"].forEach((e) => data.add(ImageWrapper.fromJson(e)));

      return PagedList(data, result["totalElements"], result["totalPages"]);
    }, result);
  }

  /// Fetch the board images without any filters
  Future<List<ImageData>> getImageBoardNonFiltered(String category) async {
    final result = await Session.proxy.get('/images/all_non_filtered?category=$category');

    return isolate.compute((response) {
      final List<ImageData> data = [];
      result.forEach((e) => data.add(ImageData.fromJson(e)));

      return data;
    }, result);
  }

  /// Fetch a single image
  Future<Uint8List> getImage(BuildContext context, String imagePath, bool isCompressed) =>
      isolate.compute((_) async => await Session.proxy.get('/files/image?image_path=$imagePath&compressed=$isCompressed&platform=${getRunningPlatform(context)}'), null);

  /// Edit an image
  Future<ImageData> editImage(ImageData toEdit) async {
    final result = await Session.proxy.put('/images/edit', data: toEdit.toJson());

    return isolate.compute((response) => ImageData.fromJson(result), result);
  }

  /// Upload an image
  Future<ImageWrapper> uploadImage({
    required bool isLandscape,
    required bool isRect,
    required String comment,
    required String category,
    required double screenWidth,
    required double screenHeight,
    String? lat,
    String? lng,
    required File file
  }) async {
    if(lat != null && lng != null) {
      final result = await Session.proxy.postFile(
          '/files/upload_image?is_landscape=$isLandscape&is_rect=$isRect&comment=$comment&category=$category&screen_width=$screenWidth&screen_height=$screenHeight&lat=$lat&lng=$lng',
          file: file
      );
      return isolate.compute((response) => ImageWrapper.fromJson(result), result);
    } else {
      final result = await Session.proxy.postFile(
          '/files/upload_image?is_landscape=$isLandscape&is_rect=$isRect&comment=$comment&category=$category&screen_width=$screenWidth&screen_height=$screenHeight',
          file: file
      );
      return isolate.compute((response) => ImageWrapper.fromJson(result), result);
    }
  }

  /// Delete an image
  Future<ImageData> deleteImage(int id) async {
    final result = await Session.proxy.delete('/files/delete_image?id=$id');

    return isolate.compute((response) => ImageData.fromJson(result), result);
  }

  /// Fetch a single image
  String getCompressedPhotograph(BuildContext context, String imagePath, bool thumbnail) =>
      !thumbnail
          ? '${Session.proxy.host}/files/image?image_path=$imagePath&compressed=true&platform=${getRunningPlatform(context)}'
          : '${Session.proxy.host}/files/thumbnail?video_path=$imagePath';
}