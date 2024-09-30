import 'package:contrast/common/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders an animated carousel widget
class AnimatedCarousel extends HookConsumerWidget {
  /// Children widgets to be rendered
  final List<Widget> children;
  /// What happens when
  final void Function(int)? onPageChanged;
  /// When should the glass animation be shown
  final void Function(AnimationController)? whenShouldAnimateGlass;
  /// When it should programmatically go to another page
  final void Function(PageController)? goToPage;
  /// Axis of scrolling
  final Axis axis;

  const AnimatedCarousel({required this.children, this.onPageChanged, this.whenShouldAnimateGlass, this.goToPage, this.axis = Axis.vertical, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Controller for the page view
    final PageController pageController = usePageController();
    /// Represents the max height of the widget
    final double widgetMaxHeight = MediaQuery.of(context).size.height;
    /// Represents the max width of the widget
    final double widgetMaxWidth = MediaQuery.of(context).size.width;
    if (goToPage != null) {
      goToPage!(pageController);
    }

    return Stack(
      children: [
        PageView.builder(
          pageSnapping: false,
          scrollDirection: axis,
          controller: pageController,
          itemCount: children.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final widget = children[index];
            double page = 0.0;
            return AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  try {
                    page = pageController.page!;
                  } catch (e) {
                    // Do nothing
                  }

                  page = index.toDouble();

                  return Align(
                    alignment: index > page ? Alignment.centerLeft : Alignment.centerRight,
                    child: child,
                  );
                },
                child: widget
            );
          },
          onPageChanged: onPageChanged,
        ),
        GlassWidget(
          whenShouldAnimateGlass: whenShouldAnimateGlass,
          width: widgetMaxWidth,
          height: widgetMaxHeight,
        )
      ],
    );
  }
}
