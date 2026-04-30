/// Helper สำหรับ path ใน Firestore ตามโครงสร้างใน docs/firebase_design.md
/// ใช้เมื่อ implement repository รุ่น Firebase
class FirestorePaths {
  FirestorePaths._();

  static String store(String storeId) => 'stores/$storeId';

  static String storeProducts(String storeId) => 'stores/$storeId/products';
  static String storeProduct(String storeId, String productId) =>
      'stores/$storeId/products/$productId';

  static String storeMembers(String storeId) => 'stores/$storeId/members';
  static String storeMember(String storeId, String memberId) =>
      'stores/$storeId/members/$memberId';

  static String storeCategories(String storeId) => 'stores/$storeId/categories';
  static String storeCategory(String storeId, String categoryId) =>
      'stores/$storeId/categories/$categoryId';

  static String storeSales(String storeId) => 'stores/$storeId/sales';
  static String storeSale(String storeId, String saleId) =>
      'stores/$storeId/sales/$saleId';
  static String storeSaleLineItems(String storeId, String saleId) =>
      'stores/$storeId/sales/$saleId/line_items';
  static String storeSaleLineItem(String storeId, String saleId, String lineItemId) =>
      'stores/$storeId/sales/$saleId/line_items/$lineItemId';

  /// ตั้งค่าสะสมคะแนน (แทน SharedPreferences)
  static String storeSettingsLoyalty(String storeId) =>
      'stores/$storeId/settings/loyalty';

  static String user(String uid) => 'users/$uid';
}
