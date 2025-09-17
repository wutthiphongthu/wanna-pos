import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthTokenExpired>(_onAuthTokenExpired);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          emit(AuthAuthenticated(
            userId: userData['userId']!,
            username: userData['userId']!, // ใช้ userId แทน username ชั่วคราว
            userRole: userData['userRole']!,
            userEmail: userData['userEmail']!,
            userFullName: userData['userFullName']!,
          ));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'เกิดข้อผิดพลาดในการตรวจสอบสถานะการเข้าสู่ระบบ'));
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await _authService.login(event.username, event.password);

      if (result['success'] == true) {
        final userData = result['data'] as Map<String, dynamic>;
        emit(AuthAuthenticated(
          userId: userData['userId']!,
          username: userData['username']!,
          userRole: userData['userRole']!,
          userEmail: userData['userEmail']!,
          userFullName: userData['userFullName']!,
        ));
      } else {
        emit(AuthError(message: result['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ'));
      }
    } catch (e) {
      emit(AuthError(message: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'เกิดข้อผิดพลาดในการออกจากระบบ'));
    }
  }

  Future<void> _onAuthTokenExpired(
      AuthTokenExpired event, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(AuthUnauthenticated());
  }
}
