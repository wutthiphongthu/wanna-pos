/// สถานะซิงก์ใน SQLite (`sync_status`)
class SyncStatus {
  SyncStatus._();

  static const int clean = 0;
  static const int dirty = 1;
  static const int pendingDelete = 2;
}
