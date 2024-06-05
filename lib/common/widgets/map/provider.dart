import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for current lng of the map
final mapLngProvider = StateNotifierProvider<MapLngNotifier, double>((ref) => MapLngNotifier(ref: ref));
/// Notifier for handling the current lng of the map
class MapLngNotifier extends StateNotifier<double> {
  /// Reference
  final Ref ref;

  MapLngNotifier({required this.ref}) : super(0);

  /// Sets the current lng of the map
  setCurrentLng(double index) => state = index;
}

/// Provider for current lat of the map
final mapLatProvider = StateNotifierProvider<MapLatNotifier, double>((ref) => MapLatNotifier(ref: ref));
/// Notifier for handling the current lat of the map
class MapLatNotifier extends StateNotifier<double> {
  /// Reference
  final Ref ref;

  MapLatNotifier({required this.ref}) : super(0);

  /// Sets the current lat of the map
  setCurrentLat(double index) => state = index;
}
