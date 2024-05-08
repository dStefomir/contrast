import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:shimmer/shimmer.dart';

/// Renders a splash page with my logo
class SplashPage extends HookConsumerWidget {

  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => BackgroundPage(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          IconRenderer(
              asset: 'background_portrait.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              color: Colors.white.withOpacity(0.15)
          ).oneShot(
              duration: const Duration(seconds: 2),
              curve: Curves.fastOutSlowIn)
              .scaleOut(start: 2, end: 0)
              .oneShot(
            duration: const Duration(seconds: 8),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
          BlurryContainer(
            child: Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.white.withOpacity(0.8),
              period: const Duration(milliseconds: 2500),
              child: const IconRenderer(asset: 'logo.svg')
                  .blurIn()
                  .oneShot(
                  duration: const Duration(seconds: 2),
                  curve: Curves.fastOutSlowIn)
                  .scaleIn(start: 0, end: 2)
                  .oneShot(
                  duration: const Duration(seconds: 3),
                  curve: Curves.fastOutSlowIn,
                  onEnd: () => Modular.to.pushNamed('/board')
              )
            ),
          )
        ],
      )
  );
}