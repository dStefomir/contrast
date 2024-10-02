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
  /// When should the glass animation be shown
  final void Function(AnimationController)? whenShouldAnimateGlass;
  /// When it should programmatically go to another page
  final void Function(PageController)? goToPage;
  /// Axis of scrolling
  final Axis axis;

  const AnimatedCarousel({required this.children, this.animation, this.onPageChanged, this.whenShouldAnimateGlass, this.goToPage, this.axis = Axis.vertical, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width;
    final maxHeight = size.height;
    /// Current position of the scroll
    final scrollPosition = useState(0.0);
    /// Controller for the page view
    final PageController pageController = usePageController();
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

        // Calculate the scroll offset for scaling
        double scale = _maxScale;
        if (pageController.hasClients) {
          final currentPage = scrollPosition.value;

          // If the index is the current or the next one, adjust the scale
          if (index == currentPage.floor()) {
            scale = _maxScale - (currentPage - index) * _scalingDifference;  // Scale down
          } else if (index == currentPage.floor() + _maxScale) {
            scale = _scaleFactor + (currentPage - (index - _maxScale)) * _scalingDifference;  // Scale up
          }
        }

        return Transform.scale(
          scale: scale.clamp(_scaleFactor, _maxScale), // Clamp scale between 0.8 and 1.0
          child: widget,
        );
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
