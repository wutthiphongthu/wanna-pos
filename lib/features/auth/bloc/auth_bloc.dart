import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/sync/sync_manager.dart';
import '../services/auth_service_interface.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthService _authService;
  final SyncManager _syncManager;

  AuthBloc(this._authService, this._syncManager) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthTokenExpired>(_onAuthTokenExpired);
    on<StoreCreated>(_onStoreCreated);
  }

  Future<void> _onStoreCreated(StoreCreated event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userData = await _authService.getCurrentUser();
      if (userData == null) {
        emit(AuthUnauthenticated());
        return;
      }
      final hasStore = await _authService.hasStore();
      if (hasStore) {
        emit(AuthAuthenticated(
          userId: userData['userId']!,
          username: userData['userId']!,
          userRole: userData['userRole']!,
          userEmail: userData['userEmail']!,
          userFullName: userData['userFullName']!,
          storeId: userData['storeId'] ?? '1',
          storeName: userData['storeName'] ?? '',
        ));
        await _syncManager.syncAllOnLogin();
      } else {
        emit(AuthNeedsStore(
          userId: userData['userId']!,
          userEmail: userData['userEmail'] ?? '',
          userFullName: userData['userFullName'] ?? '',
          userRole: userData['userRole'] ?? 'owner',
        ));
      }
    } catch (_) {
      emit(AuthError(message: 'เกิดข้อผิดพลาด'));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          final hasStore = await _authService.hasStore();
          if (hasStore) {
            emit(AuthAuthenticated(
              userId: userData['userId']!,
              username: userData['userId']!,
              userRole: userData['userRole']!,
              userEmail: userData['userEmail']!,
              userFullName: userData['userFullName']!,
              storeId: userData['storeId'] ?? '1',
              storeName: userData['storeName'] ?? '',
            ));
            await _syncManager.syncAllOnLogin();
          } else {
            emit(AuthNeedsStore(
              userId: userData['userId']!,
              userEmail: userData['userEmail'] ?? '',
              userFullName: userData['userFullName'] ?? '',
              userRole: userData['userRole'] ?? 'owner',
            ));
          }
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
        final hasStore = await _authService.hasStore();
        if (hasStore) {
          emit(AuthAuthenticated(
            userId: userData['userId']!,
            username: userData['username']!,
            userRole: userData['userRole']!,
            userEmail: userData['userEmail']!,
            userFullName: userData['userFullName']!,
            storeId: userData['storeId'] ?? '1',
            storeName: userData['storeName'] ?? '',
          ));
          await _syncManager.syncAllOnLogin();
        } else {
          emit(AuthNeedsStore(
            userId: userData['userId']!,
            userEmail: userData['userEmail']?.toString() ?? '',
            userFullName: userData['userFullName']?.toString() ?? '',
            userRole: userData['userRole']?.toString() ?? 'owner',
          ));
        }
      } else {
        emit(AuthError(message: result['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ'));
      }
    } catch (e) {
      emit(AuthError(message: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ'));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await _authService.register(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      if (result['success'] == true) {
        final userData = result['data'] as Map<String, dynamic>;
        final hasStore = await _authService.hasStore();
        if (hasStore) {
          emit(AuthAuthenticated(
            userId: userData['userId']!,
            username: userData['username']!,
            userRole: userData['userRole']!,
            userEmail: userData['userEmail']!,
            userFullName: userData['userFullName']!,
            storeId: userData['storeId'] ?? '1',
            storeName: userData['storeName'] ?? '',
          ));
          await _syncManager.syncAllOnLogin();
        } else {
          emit(AuthNeedsStore(
            userId: userData['userId']!,
            userEmail: userData['userEmail']?.toString() ?? '',
            userFullName: userData['userFullName']?.toString() ?? '',
            userRole: userData['userRole']?.toString() ?? 'owner',
          ));
        }
      } else {
        emit(AuthError(message: result['message']?.toString() ?? 'สมัครสมาชิกไม่สำเร็จ'));
      }
    } catch (e) {
      emit(AuthError(message: 'เกิดข้อผิดพลาดในการสมัครสมาชิก'));
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
