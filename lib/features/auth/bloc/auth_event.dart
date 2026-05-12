abstract class AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  LoginRequested({required this.username, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  RegisterRequested({
    required this.email,
    required this.password,
    this.displayName = '',
  });
}

class LogoutRequested extends AuthEvent {}

class AuthTokenExpired extends AuthEvent {}

/// หลังสร้างร้านเสร็จ ให้เช็คสถานะอีกครั้ง (จะได้ AuthAuthenticated)
class StoreCreated extends AuthEvent {}
