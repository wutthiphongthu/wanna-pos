class AppConstants {
  // App Info
  static const String appName = 'PPOS';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'ppos_database.db';
  static const int databaseVersion = 7;

  // API
  static const String baseUrl = 'https://api.dohome.com';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userFullNameKey = 'user_full_name';
  static const String storeIdKey = 'store_id';
  static const String storeNameKey = 'store_name';

  // Error Messages
  static const String networkErrorMessage = 'Network error occurred';
  static const String serverErrorMessage = 'Server error occurred';
  static const String databaseErrorMessage = 'Database error occurred';
  static const String unknownErrorMessage = 'Unknown error occurred';
  static const String validationErrorMessage = 'Validation error occurred';

  // Success Messages
  static const String saveSuccessMessage = 'Data saved successfully';
  static const String updateSuccessMessage = 'Data updated successfully';
  static const String deleteSuccessMessage = 'Data deleted successfully';

  // Validation Messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidEmailMessage =
      'Please enter a valid email address';
  static const String invalidPhoneMessage = 'Please enter a valid phone number';
  static const String invalidAmountMessage = 'Please enter a valid amount';

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Mobile Payment',
    'Bank Transfer',
  ];

  // Sale Status
  static const List<String> saleStatuses = [
    'Pending',
    'Completed',
    'Cancelled',
    'Refunded',
  ];

  // Membership Levels
  static const List<String> membershipLevels = [
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
  ];

  // Points / Loyalty
  /// 1 คะแนนต่อจำนวนบาทที่ซื้อ (เช่น 10 = 1 คะแนนต่อ 10 บาท)
  static const int pointsPerBaht = 10;
  /// จำนวนบาทส่วนลดต่อ 1 คะแนนเมื่อแลก (เช่น 1 = 1 คะแนนแลก 1 บาท)
  static const double bahtPerPoint = 1.0;
  /// คูณคะแนนตามระดับสมาชิก: Bronze=1, Silver=1.2, Gold=1.5, Platinum=2
  static const Map<String, double> membershipPointMultiplier = {
    'Bronze': 1.0,
    'Silver': 1.2,
    'Gold': 1.5,
    'Platinum': 2.0,
  };

  // Product Categories
  static const List<String> productCategories = [
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Sports',
    'Books',
    'Food & Beverages',
    'Health & Beauty',
    'Automotive',
    'Toys & Games',
    'Other',
  ];

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm:ss';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Currency
  static const String defaultCurrency = 'THB';
  static const String currencySymbol = '฿';

  // Timeouts
  static const Duration splashTimeout = Duration(seconds: 3);
  static const Duration sessionTimeout = Duration(hours: 24);

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];
}
