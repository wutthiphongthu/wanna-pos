class Validation {
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegExp = RegExp(r'^\+?[\d\s-()]{10,}$');
    return phoneRegExp.hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    final passwordRegExp =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  static bool isValidBarcode(String barcode) {
    // Basic barcode validation (8-13 digits)
    final barcodeRegExp = RegExp(r'^\d{8,13}$');
    return barcodeRegExp.hasMatch(barcode);
  }

  static bool isValidAmount(String amount) {
    // Valid decimal number with up to 2 decimal places
    final amountRegExp = RegExp(r'^\d+(\.\d{1,2})?$');
    return amountRegExp.hasMatch(amount);
  }

  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  static bool isValidDate(DateTime date) {
    return date.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhone(phone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateAmount(String? amount) {
    if (amount == null || amount.trim().isEmpty) {
      return 'Amount is required';
    }
    if (!isValidAmount(amount)) {
      return 'Please enter a valid amount';
    }
    return null;
  }
}
