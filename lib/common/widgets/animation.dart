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

class FadeAnimationWithRiverpod extends StatefulWidget {
  /// Child widget to be rendered
  final Widget child;
  /// Controller for handling the animations
  final AnimationController? controller;
  /// Gets triggered when animation is completed
  final Function()? onCompleted;
  /// From where the animation should start
  final double start;
  /// From where the animation should end
  final double end;
  /// Animation duration
  final Duration duration;

  /// VSYNC is need for the controller
  const FadeAnimationWithRiverpod({
    super.key,
    required this.child,
    this.controller,
    this.onCompleted,
    this.start = 1,
    this.end = 1,
    this.duration = const Duration(milliseconds: 500)
  });

  @override
  State<FadeAnimationWithRiverpod> createState() => _FadeAnimationWithRiverpodState();
}

class _FadeAnimationWithRiverpodState extends State<FadeAnimationWithRiverpod> with SingleTickerProviderStateMixin {
  /// Animation Controller
  late AnimationController controller;

  @override
  void initState() {
    controller = widget.controller ?? AnimationController(duration: widget.duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    /// Dispose the controller in the state widget
    controller.dispose();
    /// Try to dispose the controller which is passed to the holder page if not disposed there
    if(widget.controller != null && widget.controller!.isDismissed) {
      widget.controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onCompleted != null) {
        widget.onCompleted!();
      }
    });

    return FadeTransition(
      opacity: Tween<double>(begin: widget.start, end: widget.end).animate(controller..forward()),
      child: widget.child,
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

  const SlideTransitionAnimation({
    super.key,
    required this.child,
    required this.getStart,
    required this.getEnd,
    this.whenTo,
    this.onCompleted,
    this.onAnimating,
    this.duration = const Duration(microseconds: 500),
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