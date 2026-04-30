import 'package:injectable/injectable.dart';

import '../../features/auth/services/auth_service_interface.dart';
import '../utils/connectivity_service.dart';
import 'product_sync_service.dart';

/// ประสานงานซิงก์ SQLite ↔ Firestore หลัง login / resume / ปุ่ม manual
@lazySingleton
class SyncManager {
  SyncManager(
    this._connectivity,
    this._productSync,
    this._auth,
  );

  final ConnectivityService _connectivity;
  final ProductSyncService _productSync;
  final IAuthService _auth;

  Future<bool> _isOnline() async {
    final s = await _connectivity.connectivityStatus;
    return s == ConnectivityStatus.connected;
  }

  /// เรียกหลัง login สำเร็จ / สร้างร้านแล้ว
  Future<void> syncAllOnLogin() async {
    if (!await _isOnline()) return;
    try {
      await _productSync.pullFromRemote();
      await _productSync.pushDirtyLocal();
    } catch (_) {
      // ไม่บล็อก UX — ซิงก์ครั้งถัดไป
    }
  }

  Future<void> syncAllOnAppResume() async {
    if (!await _auth.isLoggedIn()) return;
    if (!await _isOnline()) return;
    try {
      await _productSync.pullFromRemote();
      await _productSync.pushDirtyLocal();
    } catch (_) {}
  }

  Future<void> syncAllManual() async {
    if (!await _isOnline()) return;
    try {
      await _productSync.pullFromRemote();
      await _productSync.pushDirtyLocal();
    } catch (_) {}
  }
}
