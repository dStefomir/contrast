import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Fade animation
class FadeAnimation extends HookConsumerWidget {
  /// Child widget
  final Widget child;
  /// When the animation should be executed
  final Function(AnimationController)? whenTo;
  /// Gets triggered when animation is completed
  final Function()? onCompleted;
  /// From where the animation should start
  final double start;
  /// From where the animation should end
  final double end;
  /// Animation duration
  final Duration duration;

  const FadeAnimation({
    super.key,
    required this.child,
    this.whenTo,
    this.onCompleted,
    this.start = 1,
    this.end = 1,
    this.duration = const Duration(milliseconds: 500)
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(duration: duration);
    if (whenTo != null) {
      whenTo!(animationController);
    }
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && onCompleted != null) {
        onCompleted!();
      }
    });

    return FadeTransition(
      opacity: Tween<double>(begin: start, end: end).animate(animationController..forward()),
      child: child,
    );
  }
}

/// Slide animation widget
class SlideTransitionAnimation extends HookConsumerWidget {
  /// Child widget
  final Widget child;
  /// When the animation should be executred
  final void Function(AnimationController)? whenTo;
  /// Gets the start of the animation
  final Offset Function() getStart;
  /// Gets the end of the animation
  final Offset Function() getEnd;
  /// Controller for the animation
  final AnimationController? controller;
  /// Duration of the animation
  final Duration duration;

  const SlideTransitionAnimation({
    super.key,
    required this.child,
    required this.getStart,
    required this.getEnd,
    this.controller,
    this.whenTo,
    this.duration = const Duration(microseconds: 500)
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AnimationController? animationController;
    if (controller == null) {
      animationController = useAnimationController(duration: duration);
    }
    if (whenTo != null) {
      whenTo!(controller ?? animationController!);
    }

    return SlideTransition(
        position: Tween<Offset>(
          begin: getStart(),
          end: getEnd(),
        ).animate(
            CurvedAnimation(
              parent: controller ?? animationController!..forward(),
              curve: Curves.ease,
            )
        ),
        child: child
    );
  }
}
