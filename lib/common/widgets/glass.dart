import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/blur.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders a glass like animation widget
class GlassWidget extends HookConsumerWidget {
  final void Function()? onFinish;
  /// When should the animation be triggered
  final void Function(AnimationController)? whenShouldAnimateGlass;
  /// Glass height
  final double height;
  /// Glass width
  final double width;
  /// Should the glass gets open or should it close
  final bool shouldOpenGlass;
  /// Animation duration
  final Duration duration;
  /// Child widget
  final Widget? child;

  const GlassWidget({
    required this.whenShouldAnimateGlass,
    this.onFinish,
    this.child,
    this.height = double.infinity,
    this.width = double.infinity,
    this.shouldOpenGlass = true,
    this.duration = const Duration(milliseconds: 10000),
    super.key
  });

  /// Render glass effect widget
  Widget _renderGlass({required double width, required double height}) => ClipRect(
    child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 5, color: Colors.black)
        ),
        child: Blurrable(
            strength: 5,
            child: SizedBox(
              width: width,
              height: height,
            )
        )
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) => Stack(
    alignment: Alignment.center,
    children: [
      Align(
          alignment: Alignment.centerLeft,
          child: SlideTransitionAnimation(
              getStart: () => shouldOpenGlass ? const Offset(0, 0) : const Offset(-1, 0),
              getEnd: () => shouldOpenGlass ? const Offset(-10, 0) : const Offset(0, 0),
              onCompleted: onFinish,
              duration: duration,
              whenTo: whenShouldAnimateGlass,
              child: _renderGlass(width: width / 2 - 9, height: height)
          )
      ),
      Align(
          alignment: Alignment.centerRight,
          child: SlideTransitionAnimation(
              getStart: () => shouldOpenGlass ? const Offset(0, 0) : const Offset(1, 0),
              getEnd: () => shouldOpenGlass ? const Offset(10, 0) : const Offset(0, 0),
              duration: duration,
              whenTo: whenShouldAnimateGlass,
              child: _renderGlass(width: width / 2 - 9, height: height)
          )
      ),
      if (child != null) child!
    ],
  );
}