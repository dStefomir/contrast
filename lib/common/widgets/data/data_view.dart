import 'dart:io';

import 'package:contrast/common/widgets/data/provider.dart';
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

/// Max blur applied to the data view
const _maxBlur = 25.0;
/// Offset for triggering the lazy load
const _lazyLoadTriggerOffset = 200;

/// Renders an grid view which fetches data from an api
class RestfulAnimatedDataView<T> extends StatefulHookConsumerWidget {
  /// Service provider for the data view
  final StateNotifierProvider <DataViewNotifier<T>, List<T>> serviceProvider;
  /// Api call
  final Future<PagedList<T>> Function(int page, String filter) loadPage;
  /// Scroll direction of the widget;
  final Axis axis;
  /// How many items per row should be shown in the grid view
  final int itemsPerRow;
  /// Padding for the data view
  final EdgeInsets? padding;
  /// Right padding added to the data view items
  final double? paddingRight;
  /// Left padding added to the data view items
  final double? paddingLeft;
  /// Renders each row of the list view
  final Widget Function(BuildContext context, int index, int dataLenght, T item, bool isLeft, bool isRight) itemBuilder;

  const RestfulAnimatedDataView({
    Key? key,
    required this.serviceProvider,
    required this.loadPage,
    required this.itemBuilder,
    this.axis = Axis.vertical,
    this.itemsPerRow = 4,
    this.padding,
    this.paddingRight,
    this.paddingLeft
  }) : super(key: key);


  @override
  ConsumerState createState() => _RestfulAnimatedDataViewState<T>();

}

class _RestfulAnimatedDataViewState<T> extends ConsumerState<RestfulAnimatedDataView<T>> with AutomaticKeepAliveClientMixin {
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
      if (event.logicalKey == LogicalKeyboardKey.arrowUp && widget.axis == Axis.vertical) {
        scrollBack(offset);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && widget.axis == Axis.vertical) {
        scrollNext(offset);
      }
    }
  }

  @override
  bool get wantKeepAlive => kIsWeb ? false : true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    /// Data view List of items
    final apiData = ref.watch(widget.serviceProvider);
    /// Check the selected filter for changes
    final String selectedFilter = ref.watch(boardHeaderTabProvider);
    /// Controller for the data view
    final ScrollController controller = useScrollController();
    /// Fetches from the back-end
    fetchData(Future fetch) => fetch.onError((error, stacktrace) async {
      await Future.delayed(const Duration(seconds: 3), () => fetchData(fetch));
    });
    /// Fetch the first page when the widget is first built.
    /// If the selected filter is changed clear the data.
    useEffect(() {
      fetchData(ref.read(widget.serviceProvider.notifier).clearAndFetchedData(widget.loadPage));
      return null;
    }, [selectedFilter]);
    
    final customScrollView = CustomScrollView(
        controller: controller,
        scrollDirection: widget.axis,
        physics: const BouncingScrollPhysics(),
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        slivers: [
          SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.itemsPerRow),
            itemBuilder: (c, i) {
              if (widget.paddingLeft != null && widget.axis == Axis.vertical && i % 3 == 0) {
                return Padding(
                  padding: EdgeInsets.only(left: widget.paddingLeft!),
                  child: widget.itemBuilder(c, i, apiData.length, apiData[i], true, false),
                );
              }
              if (widget.paddingRight != null && widget.axis == Axis.vertical && i % 3 == 2) {
                return Padding(
                  padding: EdgeInsets.only(right: widget.paddingRight!),
                  child: widget.itemBuilder(c, i, apiData.length, apiData[i], false, true),
                );
              }

              return widget.itemBuilder(c, i, apiData.length, apiData[i], false, false);
            },
            itemCount: apiData.length,
          ),
        ]
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        LazyLoadScrollView(
          onEndOfPage: () => fetchData(ref.read(widget.serviceProvider.notifier).fetchNextPage(widget.loadPage)),
          scrollOffset: _lazyLoadTriggerOffset,
          scrollDirection: widget.axis,
          child: KeyboardListener(
              autofocus: true,
              focusNode: useFocusNode(),
              onKeyEvent: (event) => _handleKeyEvent(event, controller),
              child: Listener(
                onPointerSignal: widget.axis == Axis.horizontal && kIsWeb ? (event) {
                  if (event is PointerScrollEvent) {
                    final offset = event.scrollDelta.dy;
                    if (controller.offset + offset >= 0) {
                      controller.jumpTo(controller.offset + offset);
                    }
                  }
                } : null,
                child: InertiaListener(
                    child: MotionBlur(
                      maxBlur: _maxBlur,
                      deadZone: kIsWeb || Platform.isIOS ? 10 : 20,
                      child: widget.padding != null ? Padding(padding: widget.padding!, child: customScrollView,) : customScrollView
                    )
                )
              )
          ),
        )
      ],
    );
  }
}

