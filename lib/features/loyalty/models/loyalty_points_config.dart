/// การตั้งค่าระบบสะสมคะแนน
class LoyaltyPointsConfig {
  /// 1 คะแนนต่อจำนวนบาท (เช่น 10 = 1 คะแนนต่อ 10 บาท)
  final int pointsPerBaht;

  /// โหมดหมวดหมู่: all=ทุกหมวด, include=เฉพาะที่เลือก, exclude=ยกเว้นที่เลือก
  final String categoryMode;

  /// รายชื่อหมวดหมู่ (ใช้เมื่อ mode = include หรือ exclude)
  final List<String> categoryNames;

  const LoyaltyPointsConfig({
    this.pointsPerBaht = 10,
    this.categoryMode = 'all',
    this.categoryNames = const [],
  });

  LoyaltyPointsConfig copyWith({
    int? pointsPerBaht,
    String? categoryMode,
    List<String>? categoryNames,
  }) {
    return LoyaltyPointsConfig(
      pointsPerBaht: pointsPerBaht ?? this.pointsPerBaht,
      categoryMode: categoryMode ?? this.categoryMode,
      categoryNames: categoryNames ?? this.categoryNames,
    );
  }

  /// สินค้าหมวดหมู่นี้ร่วมสะสมคะแนนหรือไม่
  bool isCategoryEligible(String categoryName) {
    if (categoryName.isEmpty) return true;
    final normalized = categoryName.trim();
    switch (categoryMode) {
      case 'all':
        return true;
      case 'include':
        return categoryNames.any((c) => c.trim().toLowerCase() == normalized.toLowerCase());
      case 'exclude':
        return !categoryNames.any((c) => c.trim().toLowerCase() == normalized.toLowerCase());
      default:
        return true;
    }
  }
}
