import 'package:book_drive_car/core/helper/validator_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidatorHelper - Email Validation', () {
    test('nên trả về true khi email đúng định dạng tiêu chuẩn', () {
      expect(ValidatorHelper.isValidEmail('user@example.com'), isTrue);
      expect(ValidatorHelper.isValidEmail('nguyen.van.a@company.vn'), isTrue);
      expect(ValidatorHelper.isValidEmail('driver_car123@gmail.com'), isTrue);
    });

    test('nên trả về false khi email thiếu ký tự @ hoặc sai tên miền', () {
      expect(ValidatorHelper.isValidEmail('userexample.com'), isFalse);
      expect(ValidatorHelper.isValidEmail('@example.com'), isFalse);
      expect(ValidatorHelper.isValidEmail('user@'), isFalse);
      expect(ValidatorHelper.isValidEmail('user@.com'), isFalse);
    });

    test('nên trả về false khi email rỗng hoặc chứa khoảng trắng', () {
      expect(ValidatorHelper.isValidEmail(''), isFalse);
      expect(ValidatorHelper.isValidEmail('   '), isFalse);
      expect(ValidatorHelper.isValidEmail('user @example.com'), isFalse);
    });
  });

  group('ValidatorHelper - Phone Number Validation', () {
    test('nên trả về true với số điện thoại Việt Nam hợp lệ (10 chữ số, bắt đầu bằng 0)', () {
      expect(ValidatorHelper.isValidPhone('0901234567'), isTrue);
      expect(ValidatorHelper.isValidPhone('0388999888'), isTrue);
      expect(ValidatorHelper.isValidPhone('0855123456'), isTrue);
    });

    test('nên trả về false khi không bắt đầu bằng số 0', () {
      expect(ValidatorHelper.isValidPhone('8490123456'), isFalse);
      expect(ValidatorHelper.isValidPhone('1901234567'), isFalse);
    });

    test('nên trả về false khi độ dài khác 10 chữ số', () {
      expect(ValidatorHelper.isValidPhone('090123456'), isFalse); // 9 số
      expect(ValidatorHelper.isValidPhone('09012345678'), isFalse); // 11 số
    });

    test('nên trả về false khi chuỗi rỗng hoặc chứa ký tự đặc biệt', () {
      expect(ValidatorHelper.isValidPhone(''), isFalse);
      expect(ValidatorHelper.isValidPhone('090abc4567'), isFalse);
      expect(ValidatorHelper.isValidPhone('090-123-456'), isFalse);
    });
  });

  group('ValidatorHelper - License Plate Validation', () {
    test('nên trả về true khi biển số xe đúng định dạng', () {
      expect(ValidatorHelper.validateLicensePlate('30A-123.45'), isTrue);
      expect(ValidatorHelper.validateLicensePlate('51F-99999'), isTrue);
      expect(ValidatorHelper.validateLicensePlate('29B12345'), isTrue);
      expect(ValidatorHelper.validateLicensePlate('43A 888.88'), isTrue);
    });

    test('nên trả về false khi biển số xe không hợp lệ', () {
      expect(ValidatorHelper.validateLicensePlate(''), isFalse);
      expect(ValidatorHelper.validateLicensePlate('ABC-123'), isFalse);
      expect(ValidatorHelper.validateLicensePlate('123456'), isFalse);
    });
  });
}
