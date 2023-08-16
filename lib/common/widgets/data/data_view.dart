import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/paged_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

/// Renders an grid view which fetches data from an api
class RestfulAnimatedDataView<T> extends HookConsumerWidget {
  /// Service provider for the data view
  final StateNotifierProvider <DataViewNotifier<T>, List<T>> serviceProvider;
  /// Api call
  final Future<PagedList<T>> Function(int page, String filter) loadPage;
  /// How many items per row should be shown in the grid view
  final int itemsPerRow;
  /// Height of the dim effect
  final double dimHeight;
  /// Renders each row of the list view
  final Widget Function(BuildContext context, int index, int dataLenght, T item) itemBuilder;
  /// What happens when the left arrow key is pressed
  final void Function()? onLeftKeyPressed;
  /// What happens when the right arrow key is pressed
  final void Function()? onRightKeyPressed;
  /// Widget that should be displayed if the list view is empty
  final Widget listEmptyChild;

  const RestfulAnimatedDataView({
    Key? key,
    required this.serviceProvider,
    required this.loadPage,
    required this.itemBuilder,
    required this.listEmptyChild,
    this.onLeftKeyPressed,
    this.onRightKeyPressed,
    this.itemsPerRow = 4,
    this.dimHeight = 0
  }) : super(key: key);

  /// Handles the keyboard key up and down for scrolling
  void _handleKeyEvent(RawKeyEvent event, ScrollController controller) {
    if (event is RawKeyDownEvent) {
      var offset = controller.offset;
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (offset != 0) {
          controller.animateTo(
              offset - 250,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final double maxScroll = controller.position.maxScrollExtent;
        final double currentScroll = controller.position.pixels;
        const double delta = 10;
        if (maxScroll - currentScroll >= delta) {
          controller.animateTo(
              offset + 250,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && onLeftKeyPressed != null) {
        onLeftKeyPressed!();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && onRightKeyPressed != null) {
        onRightKeyPressed!();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Controller for the data view
    final ScrollController controller = useScrollController();
    /// Data view List of items
    final apiData = ref.watch(serviceProvider);
    /// Check the selected filter for changes
    final String selectedFilter = ref.watch(boardHeaderTabProvider);
    /// If the selected filter is changed clear the data
    useValueChanged(
        selectedFilter, (_, __) async => ref.read(serviceProvider.notifier).clearFetchedData(loadPage)
    );
    // Fetch the first page when the widget is first built.
    useEffect(() {
        ref.read(serviceProvider.notifier).fetchNextPage(loadPage);
      return null;
    }, []);

    return apiData.isNotEmpty ? Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: dimHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        LazyLoadScrollView(
          onEndOfPage: () => ref.read(serviceProvider.notifier).fetchNextPage(loadPage),
          scrollOffset: 200,
          child: RawKeyboardListener(
              autofocus: true,
              focusNode: useFocusNode(),
              onKey: (event) => _handleKeyEvent(event, controller),
              child: GridView.builder(
                controller: controller,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: itemsPerRow),
                itemBuilder: (c, i) => itemBuilder(c, i, apiData.length, apiData[i]),
                itemCount: apiData.length,
              )
          ),
        ),
      ],
    ) : listEmptyChild;
  }
}
