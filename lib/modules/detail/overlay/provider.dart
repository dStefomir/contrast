import 'package:contrast/model/image_comments.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the photograph comments
final commentsDataViewProvider = StateNotifierProvider.autoDispose<CommentsNotifier, List<ImageCommentsData>>((ref) => CommentsNotifier(ref: ref));

/// Notifier for the photographs comments
class CommentsNotifier extends StateNotifier<List<ImageCommentsData>> {
  /// Reference
  final Ref ref;

  CommentsNotifier({required this.ref}) : super([]);

  /// Fetches the comments of a photograph
  Future<void> loadComments(int photographId, Future<List<ImageCommentsData>> Function(int) fetchComments) async {
    final comments = await fetchComments(photographId);
    state = comments;
  }

  /// Adds an comment
  void addItem(ImageCommentsData comment) {
    state.insert(0, comment);
    state = [...state];
  }

  /// Removes an comment
  void removeItem(ImageCommentsData comment) {
    state.removeWhere((e) => e.id == comment.id!);
    state = [...state];
  }

  /// Update an comment
  void updateItem(ImageCommentsData oldComment, ImageCommentsData newComment) {
    final index = state.indexOf(oldComment);
    if (index != -1) {
      state[index] = newComment;
      state = [...state];
    }
  }
}