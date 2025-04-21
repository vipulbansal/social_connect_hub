

import 'package:flutter/material.dart';

enum AuthStatus {
  uninitialized,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthService extends ChangeNotifier {
  AuthStatus get status => _status;

  // Auth state
  AuthStatus _status = AuthStatus.uninitialized;

}

