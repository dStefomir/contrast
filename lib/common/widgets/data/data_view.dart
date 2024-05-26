import 'package:contrast/common/widgets/data/provider.dart';
import 'package:contrast/common/widgets/glass.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/utils/paged_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:scrollable_inertia/scrollable_inertia.dart';

/// Renders an grid view which fetches data from an api
class RestfulAnimatedDataView<T> extends HookConsumerWidget {
  /// Service provider for the data view
  final StateNotifierProvider <DataViewNotifier<T>, List<T>> serviceProvider;
  /// Api call
  final Future<PagedList<T>> Function(int page, String filter) loadPage;
  /// Scroll direction of the widget;
  final Axis axis;
  /// How many items per row should be shown in the grid view
  final int itemsPerRow;
  /// Height of the dim effect
  final double dimHeight;
  /// Padding to be applied to the data view
  final double externalPadding;
  /// Renders each row of the list view
  final Widget Function(BuildContext context, int index, int dataLenght, T item) itemBuilder;
  /// What happens when the left arrow key is pressed
  final void Function()? onLeftKeyPressed;
  /// What happens when the right arrow key is pressed
  final void Function()? onRightKeyPressed;
  final void Function(AnimationController)? whenShouldAnimateGlass;
  /// Widget that should be displayed if the list view is empty
  final Widget listEmptyChild;

  const RestfulAnimatedDataView({
    Key? key,
    required this.serviceProvider,
    required this.loadPage,
    required this.itemBuilder,
    required this.listEmptyChild,
    this.axis = Axis.vertical,
    this.onLeftKeyPressed,
    this.onRightKeyPressed,
    this.whenShouldAnimateGlass,
    this.itemsPerRow = 4,
    this.dimHeight = 0,
    this.externalPadding = 0
  }) : super(key: key);

  /// Handles the keyboard key up and down for scrolling
  void _handleKeyEvent(KeyEvent event, ScrollController controller) {
    void scrollBack(double offset) {
      if (offset - 250 >= 0) {
        controller.animateTo(
            offset - 250,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease
        );
      }
    }
    void scrollNext(double offset) {
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
    }

    if (event is KeyDownEvent) {
      var offset = controller.offset;
      if (event.logicalKey == LogicalKeyboardKey.arrowUp && axis == Axis.vertical) {
        scrollBack(offset);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && axis == Axis.vertical) {
        scrollNext(offset);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (axis == Axis.vertical && onLeftKeyPressed != null) {
          onLeftKeyPressed!();
        } else {
          scrollBack(offset);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (axis == Axis.vertical && onRightKeyPressed != null) {
          onRightKeyPressed!();
        } else {
          scrollNext(offset);
        }
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
    /// Represents the max height of the widget
    final double widgetMaxHeight = MediaQuery.of(context).size.height;
    /// Represents the max width of the widget
    final double widgetMaxWidth = MediaQuery.of(context).size.width;
    /// Fetches from the back-end
    fetchData() => ref.read(serviceProvider.notifier)
        .clearAndFetchedData(loadPage)
        .onError((error, stackTrace) => Future.delayed(const Duration(seconds: 3), () => fetchData())
    );
    /// Fetch the first page when the widget is first built.
    /// If the selected filter is changed clear the data.
    useEffect(() {
      fetchData();
      return null;
    }, [selectedFilter]);
    
    final customScrollView = CustomScrollView(
      controller: controller,
      scrollDirection: axis,
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      slivers: [
        SliverGrid.builder(
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: itemsPerRow),
          itemBuilder: (c, i) => itemBuilder(c, i, apiData.length, apiData[i]),
          itemCount: apiData.length,
        ),
      ]
    );

    return apiData.isNotEmpty ? Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: axis == Axis.vertical ? Alignment.topCenter : Alignment.centerLeft,
          child: Container(
            height: axis == Axis.vertical ? dimHeight : null,
            width: axis == Axis.vertical ? null : dimHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: axis == Axis.vertical ? Alignment.topCenter : Alignment.centerLeft,
                end: axis == Axis.vertical ? Alignment.bottomCenter : Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: axis == Axis.vertical ? Alignment.bottomCenter : Alignment.centerRight,
          child: Container(
            height: axis == Axis.vertical ? dimHeight : null,
            width: axis == Axis.vertical ? null : dimHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: axis == Axis.vertical ? Alignment.topCenter : Alignment.centerLeft,
                end: axis == Axis.vertical ? Alignment.bottomCenter : Alignment.centerRight,
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
          scrollDirection: axis,
          child: KeyboardListener(
              autofocus: true,
              focusNode: useFocusNode(),
              onKeyEvent: (event) => _handleKeyEvent(event, controller),
              child: Listener(
                onPointerSignal: axis == Axis.horizontal && kIsWeb ? (event) {
                  if (event is PointerScrollEvent) {
                    final offset = event.scrollDelta.dy;
                    if (controller.offset + offset >= 0) {
                      controller.jumpTo(controller.offset + offset);
                    }
                  }
                } : null,
                child: !kIsWeb ? InertiaListener(
                    child: MotionBlur(
                      child: customScrollView
                    )
                ) : customScrollView
              )
          ),
        ),
        GlassWidget(
          whenShouldAnimateGlass: whenShouldAnimateGlass,
          width: widgetMaxWidth,
          height: widgetMaxHeight,
        )
      ],
    ) : listEmptyChild;
  }
}

