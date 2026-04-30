/// แหล่งที่มาของข้อมูลหลักของแอป
/// ใช้สำหรับสลับระหว่าง SQLite (ปัจจุบัน) กับ Firebase (เมื่อย้ายแล้ว) ผ่าน DI
enum AppDataSource {
  /// ใช้ฐานข้อมูล SQLite (Floor) ในเครื่อง
  sqlite,

  /// ใช้ Firebase (Firestore + Auth) เป็น backend
  firebase,
}

/// Config ว่าตอนนี้ใช้ data source ไหน
/// **โหมดหลัก: SQLite (offline-first)** — Firebase ใช้ Auth + sync ผ่าน [SyncManager]
/// ตั้งเป็น [AppDataSource.firebase] เฉพาะเมื่อต้องการทดสอบ Firestore ตรง (ไม่แนะนำ)
class AppConfig {
  AppConfig._();

  /// แหล่งข้อมูลหลัก — SQLite = offline-first; firebase = demo/legacy
  static const AppDataSource dataSource = AppDataSource.sqlite;

  static bool get useFirebase => dataSource == AppDataSource.firebase;
}
