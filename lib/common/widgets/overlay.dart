import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// This a widget to implement the image scale animation, and background grey out effect.
class AnimatedDialog extends HookConsumerWidget {
  /// Child widget
  final Widget child;
  /// width of the widget
  final double width;
  /// height of the widget
  final double height;

  const AnimatedDialog({
    Key? key,
    required this.child,
    required this.width,
    required this.height
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnimationController controller = useAnimationController(duration: const Duration(milliseconds: 400));
    final Animation<double> scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutExpo);
    final Animation<double> opacityAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutExpo));
    controller.forward();
    
    return Material(
      color: Colors.black.withOpacity(opacityAnimation.value),
      child: Center(
        child: FadeTransition(
          opacity: scaleAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
                color: Colors.black,
                width: width,
                height: height,
                child: child),
          ),
        ),
      ),
    );
  }
}
