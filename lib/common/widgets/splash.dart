import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:shimmer/shimmer.dart';

/// Renders a splash widget with my logo
class SplashWidget extends HookConsumerWidget {
  /// What should happen when the splash ends
  final void Function() onSplashEnd;

  const SplashWidget({required this.onSplashEnd, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => BackgroundPage(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.white.withOpacity(0.8),
            period: const Duration(milliseconds: 2500),
            child: const IconRenderer(asset: 'logo.svg')
                .scaleIn(start: 0, end: 2)
                .oneShot(
                duration: const Duration(seconds: 3),
                curve: Curves.fastOutSlowIn,
                onEnd: onSplashEnd
            )
          )
        ],
      )
  );
}