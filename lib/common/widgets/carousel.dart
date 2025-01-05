import 'package:contrast/common/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _maxScale = 1.0;
const _scaleFactor = 0.8;
const _scalingDifference = 0.2;

/// Renders an animated carousel widget
class AnimatedCarousel extends HookConsumerWidget {
  /// Children widgets to be rendered
  final List<Widget> children;
  /// Animation widget for the carousel
  final Widget Function(Widget)? animation;
  /// What happens when
  final void Function(int)? onPageChanged;
  /// Initial page to be rendered
  final int? initialPage;
  /// When should the glass animation be shown
  final void Function(AnimationController)? whenShouldAnimateGlass;
  /// When it should programmatically go to another page
  final void Function(PageController)? goToPage;
  /// Axis of scrolling
  final Axis axis;

  const AnimatedCarousel({required this.children, this.animation, this.onPageChanged, this.whenShouldAnimateGlass, this.goToPage, this.axis = Axis.vertical, this.initialPage, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width;
    final maxHeight = size.height;
    /// Current position of the scroll
    final scrollPosition = useState(0.0);
    /// Controller for the page view
    final PageController pageController = usePageController(initialPage: initialPage ?? 0);
    pageController.addListener(() => scrollPosition.value = pageController.page ?? 0);

    if (goToPage != null) {
      goToPage!(pageController);
    }

    final carousel = PageView.builder(
      pageSnapping: true,
      scrollDirection: axis,
      controller: pageController,
      itemCount: children.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final widget = children[index];

        return widget;
      },
      onPageChanged: onPageChanged,
    );

    return Stack(
      children: [
        if (animation != null) animation!(carousel)
        else carousel,
        GlassWidget(
          whenShouldAnimateGlass: whenShouldAnimateGlass,
          width: maxWidth,
          height: maxHeight,
        )
      ],
    );
  }
}
