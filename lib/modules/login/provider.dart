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

/// Provider for the user name
final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) => UserNameNotifier(ref: ref, userName: ''));
/// Notifier for the user name
class UserNameNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;
  /// User name
  final String userName;

  UserNameNotifier({required this.ref, required this.userName}) : super(userName);

  /// Sets the user name
  setUserName(String value) => state = value;
}

/// Provider for the user password
final userPasswordProvider = StateNotifierProvider<UserPasswordNotifier, String>((ref) => UserPasswordNotifier(ref: ref, userPassword: ''));
/// Notifier for the user password
class UserPasswordNotifier extends StateNotifier<String> {
  /// Reference
  final Ref ref;
  /// User password
  final String userPassword;

  UserPasswordNotifier({required this.ref, required this.userPassword}) : super(userPassword);

  /// Sets the user password
  setUserPassword(String value) => state = value;
}