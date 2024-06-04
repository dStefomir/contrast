import 'package:contrast/common/widgets/shader/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders a shader widget
class ShaderWidget extends StatefulHookConsumerWidget {
  /// Child widget
  final Widget? child;
  /// Asset for the shader
  final String asset;
  /// Size of the widget in pixels
  final double? size;

  const ShaderWidget({super.key, required this.asset, this.size, this.child});

  @override
  ConsumerState createState() => _ShaderWidgetState();
}

class _ShaderWidgetState extends ConsumerState<ShaderWidget> with SingleTickerProviderStateMixin {

  /// Ticker object
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
    _ticker ??= createTicker((elapsed) =>
        ref.read(shaderProvider.notifier).setTicker()
    )..start()
    );
  }

  @override
  void dispose() {
    super.dispose();
    _ticker?.stop();
    _ticker?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = ShaderBuilder(
            (_, shader, __) {
          final time = ref.watch(shaderProvider);
          shader.setFloat(0, time);

          return AnimatedSampler(
                (image, size, canvas) {
                  shader.setFloat(1, widget.size ?? size.width);
                  shader.setFloat(2, widget.size ?? MediaQuery.of(context).padding.top);
                  canvas.drawPaint(Paint()..shader = shader..filterQuality = FilterQuality.low..isAntiAlias = false);
            },
            child: widget.child ?? const SizedBox.shrink(),
          );
        },
        assetKey: 'shaders/${widget.asset}'
    );

    return widget.child != null ? Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        shader,
        widget.child!
      ],
    ) : shader;
  }
}