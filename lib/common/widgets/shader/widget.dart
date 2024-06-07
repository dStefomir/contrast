import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Value which is responsible for the animation speed
const _animationSpeed = 500;
/// Renders a shader widget
class ShaderWidget extends HookConsumerWidget {
  /// Child widget
  final Widget? child;
  /// Asset for the shader
  final String asset;
  /// Size of the widget in pixels
  final double? widgetSize;
  /// Sets a scaling for the shader
  final double Function()? scale;

  const ShaderWidget({super.key, required this.asset, this.widgetSize, this.scale, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController()..repeat(period: const Duration(hours: 1));
    final shader = ShaderBuilder(
      assetKey: 'shaders/$asset',
          (context, shader, child) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, child) => AnimatedSampler(
                  (image, size, canvas) {
                shader.setFloat(0, controller.value * _animationSpeed);
                shader.setFloat(1, widgetSize ?? size.width);
                shader.setFloat(2, widgetSize ?? MediaQuery.of(context).padding.top);
                if (scale != null) {
                  canvas.scale(scale!());
                }
                final paint = Paint()..shader = shader..isAntiAlias = false..filterQuality = FilterQuality.low;
                canvas.drawPaint(paint);
              },
              child: child ?? const SizedBox.shrink()
          ),
          child: widgetSize != null ? SizedBox(width: widgetSize ?? 120, height: 100,) : Container(),
        );
      },
    );

    return child != null ? Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        shader,
        child!
      ],
    ) : shader;
  }
}