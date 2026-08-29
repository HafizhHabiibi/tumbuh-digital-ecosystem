import 'dart:async';

enum AuthSessionEvent { expired }

class AuthSessionController {
  AuthSessionController();

  static final AuthSessionController instance = AuthSessionController();

  final StreamController<AuthSessionEvent> _events =
      StreamController<AuthSessionEvent>.broadcast();

  Stream<AuthSessionEvent> get events => _events.stream;

  void notifyExpired() {
    _events.add(AuthSessionEvent.expired);
  }
}
