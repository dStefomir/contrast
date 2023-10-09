
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the start period of planning
final startPeriodProvider = StateNotifierProvider<PlanningPeriodNotifier, DateTime?>((ref) => PlanningPeriodNotifier(ref: ref));
/// Provider for the start period of planning
final endPeriodProvider = StateNotifierProvider<PlanningPeriodNotifier, DateTime?>((ref) => PlanningPeriodNotifier(ref: ref));

/// Notifier for the period of planning
class PlanningPeriodNotifier extends StateNotifier<DateTime?> {
  /// Reference
  final Ref ref;

  PlanningPeriodNotifier({required this.ref}) : super(null);

  /// Sets the period of planning
  void setPeriod(DateTime? period) => state = period;
}