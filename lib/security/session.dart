import 'package:contrast/common/proxy.dart';
import 'package:flutter/widgets.dart';
import 'package:jwt_decode/jwt_decode.dart';

/// Session class handling the authentication of the user
class Session extends ChangeNotifier {
  /// Stores authenticated token inside
  static final Session _instance = Session._internal();
  /// JWT token
  String? _token;
  /// User email
  String? _eMail;
  /// Is the user a guest
  bool? _isGuest = false;

  // Instantiates proxy with the current token
  static Proxy get proxy {
    if (_instance._token != null) {
      return Proxy(_instance._token,
          onInvalidToken: () => _instance.logout());
    } else {
      return Proxy(null, onInvalidToken: () => null);
    }
  }
  
  /// Returns access token
  String? get token {
    return _instance._token;
  }

  /// Returns last email address which was used to sign in
  String? get eMail {
    return _instance._eMail;
  }

  bool? get isGuest {
    return _instance._isGuest;
  }

  /// Returns current user id
  int? get userId {
    if (_instance.token != null) {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(_instance.token!);

      return decodedToken['id'] as int;
    }

    return null;
  }

  /// Factory
  factory Session() => _instance;

  /// Internal named constructor
  Session._internal();
  
  /// Internal setter for the guest state
  void _setGuest(bool? isGuest) {
    _isGuest = isGuest;
    notifyListeners();
  }

  /// Internal setter for the jwt token
  void _setToken(String? value) {
    _token = value;
    notifyListeners();
  }

  /// Internal setter for the email
  void _setEMail(String? value) {
    _eMail = value;
    notifyListeners();
  }

  /// Sets the state of the guest
  set isGuest(bool? isGuest) {
    _setGuest(isGuest);
  }

  /// Sets the new access token and notifies the listeners for this change
  set token(String? value) {
    _setToken(value);
  }

  /// Sets the new email
  set eMail(String? value) {
    _setEMail(value);
  }

  /// Clears the access token and logs out, consequentially notifies the listeners to take action
  Future<void> logout() async {
    _setToken(null);
  }

  /// Indicates that the user is logged in or not.
  bool isLoggedIn() {
    return token != null;
  }
}
