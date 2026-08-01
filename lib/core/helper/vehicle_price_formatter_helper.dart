import 'package:intl/intl.dart';

class VehiclePriceFormatterHelper {
  static int? parsePriceInput(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  static String formatPriceInput(String value) {
    final number = parsePriceInput(value);
    if (number == null) return '';
    return NumberFormat.decimalPattern('vi').format(number);
  }

  static String formatCurrency(String value) {
    final number = parsePriceInput(value);
    if (number == null || number == 0) return '0';
    return NumberFormat.decimalPattern('vi').format(number);
  }
}
