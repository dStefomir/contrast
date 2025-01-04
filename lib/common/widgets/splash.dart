import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:shimmer/shimmer.dart';

/// Renders a splash widget with my logo
class SplashWidget extends HookConsumerWidget {
  /// What should happen when the splash ends
  final void Function() onSplashEnd;

  const SplashWidget({required this.onSplashEnd, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldAnimateLetters = useState(false);
    final dx = MediaQuery.of(context).size.width / 4;

    return BackgroundPage(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.white.withValues(alpha: 0.8),
                period: const Duration(milliseconds: 2500),
                child: const IconRenderer(asset: 'logo_d.svg')
            ).slideOut(Offset(dx * -1, 0))
            .animate(
                trigger: shouldAnimateLetters.value,
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastEaseInToSlowEaseOut,
                onEnd: onSplashEnd
            ),
            Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.white.withValues(alpha: 0.8),
                period: const Duration(milliseconds: 2500),
                child: const IconRenderer(asset: 'logo_s.svg')
            ).slideOut(Offset(dx, 0))
                .animate(
                trigger: shouldAnimateLetters.value,
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastEaseInToSlowEaseOut
            ),
          ],
        ).scaleIn(start: 0, end: 2)
            .oneShot(
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            onEnd: () => shouldAnimateLetters.value = true
        )
    );
  }
}