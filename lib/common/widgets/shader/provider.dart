import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the shader
final shaderProvider = StateNotifierProvider<ShaderNotifier, double>((ref) => ShaderNotifier(ref: ref));
/// Notifier for map location
class ShaderNotifier extends StateNotifier<double> {
  /// Reference
  final Ref ref;

  ShaderNotifier({required this.ref}) : super(0.1);

  /// Ticks
  void setTicker() => state = state + 0.003;
}