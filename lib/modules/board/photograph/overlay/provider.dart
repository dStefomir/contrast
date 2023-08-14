import 'dart:typed_data';

import 'package:contrast/model/image_data.dart';
import 'package:contrast/modules/board/photograph/service.dart';
import 'package:file/memory.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the selected data
final fileProvider = StateNotifierProvider.autoDispose<UploadDataNotifier, FileData>((ref) => UploadDataNotifier(ref: ref));
/// File attributes
class FileData {
  /// Bytes of the file
  final Uint8List? bytes;
  /// File name
  final String? fileName;
  /// Is the selected file a landscape photo
  final bool? isLandscape;
  /// Is the selected file a rect photo
  final bool? isRect;

  const FileData({this.bytes, this.fileName, this.isLandscape, this.isRect});

  /// Checks if a file is selected or not
  bool isFileSelected() =>
      bytes != null &&
      fileName != null &&
      isLandscape != null &&
      isRect != null;
}
/// Notifier for the selected data
class UploadDataNotifier extends StateNotifier<FileData> {
  /// Reference
  final Ref ref;

  UploadDataNotifier({required this.ref}) : super(const FileData());

  /// Sets the selected data
  setData(Uint8List? data, String? fileName, bool? isLandscape, bool? isRect) =>
      state = FileData(
          bytes: data,
          fileName: fileName,
          isLandscape: isLandscape,
          isRect: isRect
      );
}

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

/// Provider for the selected category
final categoryProvider = StateNotifierProvider.family<CategoryNotifier, String, String?>((ref, value) => CategoryNotifier(ref: ref, category: value));
/// Notifier for the loading state
class CategoryNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;
  /// Initial category
  final String? category;

  CategoryNotifier({required this.ref, this.category}) : super(category ?? 'landscape');

  /// sets the selected category
  setCategory(String value) => state = value;
}

/// Provider for the selected lat
final geoLatProvider = StateNotifierProvider.family<SelectedPhotographLatNotifier, String, double?>((ref, value) => SelectedPhotographLatNotifier(ref: ref, lat: value));
/// Notifier for handling the selected photograph lat
class SelectedPhotographLatNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;
  /// Current lat
  final double? lat;

  SelectedPhotographLatNotifier({required this.ref, this.lat}) : super(lat != null ? '$lat': '');

  /// Sets the selected photograph lat
  setLat(String value) => state = value;
}

/// Provider for the selected lng
final geoLngProvider = StateNotifierProvider.family<SelectedPhotographLngNotifier, String, double?>((ref, value) => SelectedPhotographLngNotifier(ref: ref, lng: value));
/// Notifier for handling the selected photograph lng
class SelectedPhotographLngNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;
  /// Current lng
  final double? lng;

  SelectedPhotographLngNotifier({required this.ref, this.lng}) : super(lng != null ? '$lng': '');

  /// Sets the selected photograph lng
  setLng(String value) => state = value;
}

/// Provider for the comment
final commentProvider = StateNotifierProvider<SelectedPhotographCommentNotifier, String>((ref) => SelectedPhotographCommentNotifier(ref: ref));
/// Notifier for handling the photograph comment
class SelectedPhotographCommentNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;

  SelectedPhotographCommentNotifier({required this.ref}) : super("");

  /// Sets the selected photograph comment
  setComment(String value) => state = value;
}

/// Provider for posting a file to an api
final uploadPhotographProvider = StateNotifierProvider<FileServiceNotifier, AsyncValue<String>>((ref) => FileServiceNotifier(ref: ref));
/// Notifier for posting a file to an api
class FileServiceNotifier extends StateNotifier<AsyncValue<String>> {
  /// Reference
  final Ref ref;

  FileServiceNotifier({required this.ref}) : super(const AsyncValue.loading());

  /// Edits a file
  Future<ImageData> editFile(ImageData data, String selectedCategory, String lat, String lng) async {
    final String comment = ref.read(commentProvider);
    final serviceProvider = ref.watch(photographyBoardServiceProvider);
    final updatedPhotograph = await serviceProvider.editImage(
        ImageData(
            id: data.id,
            isRect: data.isRect,
            isLandscape: data.isLandscape,
            category: selectedCategory,
            comment: comment,
            dx: data.dx,
            dy: data.dy,
            initialScreenHeight: data.initialScreenHeight,
            initialScreenWidth: data.initialScreenWidth,
            lat: lat.isNotEmpty ? double.parse(lat) : null,
            lng: lng.isNotEmpty ? double.parse(lng) : null,
            path: data.path
        )
    );
    state = const AsyncValue.data('OK');
    return updatedPhotograph;
  }

  /// Posts a file
  Future<ImageWrapper> postFile(String selectedCategory, String lat, String lng) async {
    final FileData selectedFileData = ref.read(fileProvider);
    final String comment = ref.read(commentProvider);
    final serviceProvider = ref.watch(photographyBoardServiceProvider);
    final ImageWrapper result = await serviceProvider.uploadImage(
        isLandscape: selectedFileData.isLandscape!,
        isRect: selectedFileData.isRect!,
        comment: comment,
        category: selectedCategory,
        screenWidth: 0,
        screenHeight: 0,
        lat: lat,
        lng: lng,
        file: MemoryFileSystem().file(selectedFileData.fileName)
          ..writeAsBytesSync(selectedFileData.bytes!)
    );
    state = const AsyncValue.data("OK");
    return result;
  }
}

/// Provider for editing an image
final photographEditProvider = StateNotifierProvider<EditImageNotifier, ImageData?>((ref) => EditImageNotifier(ref: ref));
/// Notifier for editing an image
class EditImageNotifier extends StateNotifier<ImageData?> {
  /// Reference
  final Ref ref;

  EditImageNotifier({required this.ref}) : super(null);

  /// Sets a selected image for edit
  void setEditImage(ImageData? image) => state = image;
}