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
  final void Function()? onCompleted;
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
  /// When the animation should be executed
  final void Function(AnimationController)? whenTo;
  /// Gets triggered when animation is completed
  final void Function()? onCompleted;
  /// Gets triggered when animation is running
  final void Function()? onAnimating;
  /// Gets the start of the animation
  final Offset Function() getStart;
  /// Gets the end of the animation
  final Offset Function() getEnd;
  /// Duration of the animation
  final Duration duration;
  /// Should the animation repeat itself
  final bool repeat;

  const SlideTransitionAnimation({
    super.key,
    required this.child,
    required this.getStart,
    required this.getEnd,
    this.whenTo,
    this.onCompleted,
    this.onAnimating,
    this.duration = const Duration(microseconds: 500),
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AnimationController? animationController = useAnimationController(duration: duration);
    if (whenTo != null) {
      whenTo!(animationController);
    }
    if(onAnimating != null) {
      animationController.addListener(() => onAnimating!());
    }
    if(onCompleted != null) {
      animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed && onCompleted != null) {
          onCompleted!();
        }
      });
    }
    if(repeat) {
      animationController.addStatusListener((status) {
        if(status == AnimationStatus.completed) {
          animationController.reset();
          animationController.forward();
        }
      });
    }

    return SlideTransition(
        position: Tween<Offset>(
          begin: getStart(),
          end: getEnd(),
        ).animate(
            CurvedAnimation(
              parent: animationController..forward(),
              curve: Curves.ease,
            )
        ),
        child: child
    );
  }
}