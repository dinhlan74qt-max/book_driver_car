import 'package:book_drive_car/core/helper/vehicle_price_formatter_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VehiclePriceFormatterHelper', () {
    test('parsePriceInput nên bóc tách chính xác số từ chuỗi định dạng tiền tệ', () {
      expect(VehiclePriceFormatterHelper.parsePriceInput('800.000 đ'), equals(800000));
      expect(VehiclePriceFormatterHelper.parsePriceInput('1,500,000 VND'), equals(1500000));
      expect(VehiclePriceFormatterHelper.parsePriceInput('500000'), equals(500000));
      expect(VehiclePriceFormatterHelper.parsePriceInput(''), isNull);
      expect(VehiclePriceFormatterHelper.parsePriceInput('abc!@#'), isNull);
    });

    test('formatPriceInput nên định dạng số thành chuỗi phân cách hàng nghìn', () {
      expect(VehiclePriceFormatterHelper.formatPriceInput('800000'), equals('800.000'));
      expect(VehiclePriceFormatterHelper.formatPriceInput('1250000'), equals('1.250.000'));
      expect(VehiclePriceFormatterHelper.formatPriceInput(''), equals(''));
      expect(VehiclePriceFormatterHelper.formatPriceInput('abc'), equals(''));
    });

    test('formatCurrency nên trả về "0" khi đầu vào rỗng hoặc bằng 0', () {
      expect(VehiclePriceFormatterHelper.formatCurrency(''), equals('0'));
      expect(VehiclePriceFormatterHelper.formatCurrency('0'), equals('0'));
      expect(VehiclePriceFormatterHelper.formatCurrency('abc'), equals('0'));
      expect(VehiclePriceFormatterHelper.formatCurrency('450000'), equals('450.000'));
    });
  });
}
