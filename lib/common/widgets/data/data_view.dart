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

/// Max blur applied to the data view
const _maxBlur = 55.0;
/// Used for defining the non blurry zone
const _nonBlurryZone = 100.0;
/// Used for defining the blurry zone
const _blurryZone = 15.0;
/// Offset for triggering the lazy load
const _lazyLoadTriggerOffset = 200;

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

  /// Handles the motion blur scrolling of the data view
  _handleMotionBlurDeadZone({required ScrollController controller, required ValueNotifier<double> deadZone}) {
    if (controller.hasClients) {
      /// The top items are been shown
      if (controller.offset <= _nonBlurryZone) {
        deadZone.value = _nonBlurryZone;
        /// The last items are been shown
      } else if (controller.position.pixels >= controller.position.maxScrollExtent) {
        deadZone.value = _nonBlurryZone;
        /// All other items
      } else {
        deadZone.value = _blurryZone;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Data view List of items
    final apiData = ref.watch(serviceProvider);
    /// Check the selected filter for changes
    final String selectedFilter = ref.watch(boardHeaderTabProvider);
    /// Represents the max height of the widget
    final double widgetMaxHeight = MediaQuery.of(context).size.height;
    /// Represents the max width of the widget
    final double widgetMaxWidth = MediaQuery.of(context).size.width;
    /// Controller for the data view
    final ScrollController controller = useScrollController();
    final motionBlurDeadZone = useValueNotifier(_nonBlurryZone);
    controller.addListener(() => _handleMotionBlurDeadZone(controller: controller, deadZone: motionBlurDeadZone));
    /// Fetches from the back-end
    fetchData(Future fetch) => fetch.onError((error, stacktrace) async {
      await Future.delayed(const Duration(seconds: 3), () => fetchData(fetch));
    });
    /// Fetch the first page when the widget is first built.
    /// If the selected filter is changed clear the data.
    useEffect(() {
      fetchData(ref.read(serviceProvider.notifier).clearAndFetchedData(loadPage));
      return null;
    }, [selectedFilter]);
    
    final customScrollView = CustomScrollView(
      controller: controller,
      scrollDirection: axis,
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
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: itemsPerRow),
          itemBuilder: (c, i) => InertiaSpacing(
              maxStretch: 10,
              child: itemBuilder(c, i, apiData.length, apiData[i])
          ),
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
          onEndOfPage: () => fetchData(ref.read(serviceProvider.notifier).fetchNextPage(loadPage)),
          scrollOffset: _lazyLoadTriggerOffset,
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
                child: InertiaListener(
                    child: MotionBlur(
                      maxBlur: _maxBlur,
                      deadZone: useValueListenable<double>(motionBlurDeadZone),
                      child: customScrollView
                    )
                )
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

