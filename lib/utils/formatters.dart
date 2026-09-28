import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');

  static String formatCurrency(double amount) {
    return 'Rs. ${_currencyFormat.format(amount)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  // Bulk discount calculation
  static double getBulkDiscountPercent(int quantity) {
    if (quantity >= 100) return 0.15; // 15% discount for 100+ kg
    if (quantity >= 50) return 0.10;  // 10% discount for 50+ kg
    return 0.0;
  }

  static double calculateTotal(double unitPrice, int quantity) {
    final subtotal = unitPrice * quantity;
    final discount = subtotal * getBulkDiscountPercent(quantity);
    return subtotal - discount;
  }
}
