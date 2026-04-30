abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String username;
  final String userRole; // 'owner' = เจ้าของร้าน, 'employee' = พนักงาน
  final String userEmail;
  final String userFullName;
  final String storeId;
  final String storeName;

  AuthAuthenticated({
    required this.userId,
    required this.username,
    required this.userRole,
    required this.userEmail,
    required this.userFullName,
    this.storeId = '1',
    this.storeName = '',
  });

  bool get isOwner => userRole == 'owner';
  bool get isEmployee => userRole == 'employee';
}

class AuthUnauthenticated extends AuthState {}

/// ผ่าน auth แล้วแต่ยังไม่มีร้าน — ต้องสร้างร้านก่อนเข้าแอป
class AuthNeedsStore extends AuthState {
  final String userId;
  final String userEmail;
  final String userFullName;
  final String userRole;

  AuthNeedsStore({
    required this.userId,
    required this.userEmail,
    required this.userFullName,
    this.userRole = 'owner',
  });
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
