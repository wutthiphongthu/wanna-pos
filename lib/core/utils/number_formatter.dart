import 'package:intl/intl.dart';

class NumberFormatter {
  // Format number with comma separator (123,456.78)
  static String formatNumber(num value, {int decimalPlaces = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}', 'en_US');
    return formatter.format(value);
  }

  // Format currency with Thai Baht symbol (฿123,456.78)
  static String formatCurrency(num value, {int decimalPlaces = 2}) {
    final formatted = formatNumber(value, decimalPlaces: decimalPlaces);
    return '฿$formatted';
  }

  // Format currency without symbol (123,456.78)
  static String formatCurrencyValue(num value, {int decimalPlaces = 2}) {
    return formatNumber(value, decimalPlaces: decimalPlaces);
  }

  // Format integer with comma separator (123,456)
  static String formatInteger(int value) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(value);
  }

  // Format percentage (12.34%)
  static String formatPercentage(num value, {int decimalPlaces = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}%', 'en_US');
    return formatter.format(value);
  }

  // Parse formatted number back to double
  static double? parseFormattedNumber(String formattedValue) {
    try {
      // Remove currency symbol and commas
      String cleanValue =
          formattedValue.replaceAll('฿', '').replaceAll(',', '').trim();

      return double.tryParse(cleanValue);
    } catch (e) {
      return null;
    }
  }

  // Format stock quantity with unit
  static String formatStock(int quantity, {String unit = 'ชิ้น'}) {
    return '${formatInteger(quantity)} $unit';
  }

  // Format price range (฿100 - ฿500)
  static String formatPriceRange(num minPrice, num maxPrice) {
    return '${formatCurrency(minPrice)} - ${formatCurrency(maxPrice)}';
  }

  // Format discount (Save ฿123.45)
  static String formatDiscount(num discountAmount) {
    return 'ประหยัด ${formatCurrency(discountAmount)}';
  }

  // Format profit margin (12.34%)
  static String formatProfitMargin(num cost, num price) {
    if (cost <= 0) return '0.00%';
    final margin = ((price - cost) / cost) * 100;
    return formatPercentage(margin / 100);
  }
}
