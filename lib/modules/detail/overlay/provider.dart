import 'package:contrast/model/image_comments.dart';
import 'package:contrast/model/video_comments.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

///----------------------------------- List all service fetching providers here -----------------------------------///
/// Provider for the photograph comments
final imageCommentsDataViewProvider = StateNotifierProvider<CommentsNotifier<ImageCommentsData>, List<ImageCommentsData>>((ref) => CommentsNotifier(ref: ref));
/// Provider for the video comments
final videoCommentsDataViewProvider = StateNotifierProvider<CommentsNotifier<VideoCommentsData>, List<VideoCommentsData>>((ref) => CommentsNotifier(ref: ref));
///----------------------------------------------------------------------------------------------------------------///

/// Notifier for the photographs comments
class CommentsNotifier<T> extends StateNotifier<List<T>> {
  /// Reference
  final Ref ref;

  CommentsNotifier({required this.ref}) : super([]);

  /// Fetches the comments of a photograph
  Future<void> loadComments(int id, bool isAdmin, Future<List<T>> Function(int, bool) fetchComments) async {
    final comments = await fetchComments(id, isAdmin);
    state = comments;
  }

  /// Adds an comment
  void addItem(T comment) {
    state.insert(0, comment);
    state = [...state];
  }

  /// Removes an comment
  void removeItem(int index) {
    state.removeAt(index);
    state = [...state];
  }

  /// Update an comment
  void updateItem(T oldComment, T newComment) {
    final index = state.indexOf(oldComment);
    if (index != -1) {
      state[index] = newComment;
      state = [...state];
    }
  }
}