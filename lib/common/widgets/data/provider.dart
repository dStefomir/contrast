import 'package:contrast/model/image_data.dart';
import 'package:contrast/model/video_data.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/paged_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

///----------------------------------- List all service fetching providers here -----------------------------------///
/// Service provider for the data view
final photographServiceFetchProvider = StateNotifierProvider<DataViewNotifier<ImageWrapper>, List<ImageWrapper>>((ref) => DataViewNotifier<ImageWrapper>(ref: ref));
/// Service provider for the data view
final videoServiceFetchProvider = StateNotifierProvider<DataViewNotifier<VideoData>, List<VideoData>>((ref) => DataViewNotifier<VideoData>(ref: ref));

///----------------------------------------------------------------------------------------------------------------///

/// Pagination notifier for the data view
class DataViewNotifier<T> extends StateNotifier<List<T>> {
  /// Reference
  final Ref ref;
  /// Current fetched page
  late int _currentPage;

  DataViewNotifier({required this.ref}) : super([]) {
    _currentPage = 1;
  }

  /// Fetches the next page of data
  Future<void> fetchNextPage(
      Future<PagedList<T>> Function(int, String) fetchPage) async {
    final String selectedFilter = ref.read(boardHeaderTabProvider);
    final nextPageItems = await fetchPage(_currentPage, selectedFilter);
    state = [...state, ...nextPageItems];
    _currentPage++;
  }

  /// Clears the fetched data and resets the current page
  void clearFetchedData(Future<PagedList<T>> Function(int, String) fetchPage) async {
    state.clear();
    _currentPage = 1;
    await fetchNextPage(fetchPage);
  }

  /// Adds an item
  void addItem(T item) {
    final List<T> currentState = state;
    currentState.insert(0, item);
    state = [...state, ...currentState];
  }

  /// Removes an item
  void removeItem(T item) {
    state.remove(item);
    state = [...state];
  }

  /// Update an item
  void updateItem(T oldItem, T newItem) {
    final index = state.indexOf(oldItem);
    if (index != -1) {
      state[index] = newItem;
      state = [...state];
    }
  }
}