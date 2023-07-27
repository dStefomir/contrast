import 'package:contrast/security/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for session
final sessionProvider = StateNotifierProvider.autoDispose<SessionNotifier, Session>((ref) => SessionNotifier(ref: ref));
/// Notifier for session
class SessionNotifier extends StateNotifier<Session> {
  /// Reference
  final Ref ref;

  SessionNotifier({required this.ref}) : super(Session());
}