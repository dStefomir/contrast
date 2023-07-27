import 'package:contrast/security/session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the authentication service
final authenticationServiceProvider = Provider<AuthenticationService>((ref) => AuthenticationService());
/// Authentication service
class AuthenticationService {
  /// Logs the adin user in
  Future<String> login(String user, String password) async {
    final result = await Session.proxy.post('/auth/login', data: {'user': user, 'pwd': password});

    return result['token'];
  }
}
