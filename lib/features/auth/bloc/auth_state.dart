abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String username;
  final String userRole;
  final String userEmail;
  final String userFullName;

  AuthAuthenticated({
    required this.userId,
    required this.username,
    required this.userRole,
    required this.userEmail,
    required this.userFullName,
  });
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
