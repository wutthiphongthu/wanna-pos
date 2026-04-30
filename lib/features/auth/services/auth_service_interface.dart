/// Interface สำหรับ Auth — ใช้ทั้งรุ่น Mock/SQLite และ Firebase
/// DI จะ inject implementation ตาม AppConfig.useFirebase
abstract class IAuthService {
  Future<bool> isLoggedIn();
  Future<Map<String, String>?> getCurrentUser();
  Future<int> getCurrentStoreId();
  Future<String> getCurrentStoreName();
  /// ผู้ใช้ผ่าน auth แล้วและมีร้านค้าของตัวเองหรือยัง (ถ้าไม่มีต้องสร้างร้านก่อนเข้าแอป)
  Future<bool> hasStore();
  /// หลังสร้างร้านแล้ว ตั้งค่า store ให้ user ปัจจุบัน (Firebase: อัปเดต user doc + storage)
  Future<void> setStoreForCurrentUser(String storeId, String storeName);
  Future<Map<String, dynamic>> login(String username, String password);
  Future<void> logout();
}
