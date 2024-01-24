import 'package:contrast/common/widgets/shader/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders a shader widget
class ShaderWidget extends StatefulHookConsumerWidget {
  /// Child widget
  final Widget child;
  /// Asset for the shader
  final String asset;

  const ShaderWidget({super.key, required this.asset, this.child = const SizedBox.shrink()});

  @override
  ConsumerState createState() => ShaderWidgetState();
}

class ShaderWidgetState extends ConsumerState<ShaderWidget> with SingleTickerProviderStateMixin {

  /// Ticker object
  late Ticker ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ticker = createTicker((elapsed) =>
            ref.read(shaderProvider.notifier).setTicker()
        )..start()
    );
  }

  @override
  void dispose() {
    super.dispose();
    ticker.stop();
    ticker.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ShaderBuilder(
                (_, shader, __) {
                  final time = ref.watch(shaderProvider);
                  return AnimatedSampler(
                        (image, size, canvas) {
                          shader.setFloat(0, time);
                          shader.setFloat(1, size.width);
                          shader.setFloat(2, size.height);
                          canvas.drawPaint(Paint()..shader = shader);
                          },
                    child: widget.child,
                  );
                  },
            assetKey: 'shaders/${widget.asset}'
        ),
        widget.child
      ],
    );
  }
}