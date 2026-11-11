import 'package:book_drive_car/features/auth/data/models/auth_result_model.dart';
import 'package:book_drive_car/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel - fromJson', () {
    test('nên deserialize thành công từ JSON đầy đủ', () {
      final json = {
        'id': 12,
        'fullname': 'Trần Thị B',
        'email': 'tranthib@gmail.com',
        'phone': '0987654321',
        'cccd': '001234567890',
        'address': 'Quận Ba Đình, Hà Nội',
        'avatar': 'https://example.com/avatar.jpg',
        'role': 'renter',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals(12));
      expect(user.fullname, equals('Trần Thị B'));
      expect(user.email, equals('tranthib@gmail.com'));
      expect(user.phone, equals('0987654321'));
      expect(user.cccd, equals('001234567890'));
      expect(user.address, equals('Quận Ba Đình, Hà Nội'));
      expect(user.avatar, equals('https://example.com/avatar.jpg'));
      expect(user.role, equals('renter'));
    });

    test('nên tương thích khi key là userId hoặc user_id và role mặc định là user', () {
      final json1 = {
        'userId': '55',
        'fullName': 'Lê Văn C',
        'email': 'levanc@gmail.com',
        'phone': '0911223344',
      };

      final user1 = UserModel.fromJson(json1);
      expect(user1.id, equals(55));
      expect(user1.fullname, equals('Lê Văn C'));
      expect(user1.role, equals('user'));

      final json2 = {
        'user_id': 66,
        'fullname': 'Phạm Văn D',
        'email': 'phamd@gmail.com',
        'phone': '0933445566',
      };

      final user2 = UserModel.fromJson(json2);
      expect(user2.id, equals(66));
    });
  });

  group('AuthResultModel - fromJson', () {
    test('nên deserialize trọn vẹn đối tượng auth chứa token và user lồng nhau', () {
      final json = {
        'token': 'jwt_access_token_xyz_999',
        'tokenType': 'Bearer',
        'user': {
          'id': 1,
          'fullname': 'Admin User',
          'email': 'admin@carnow.vn',
          'phone': '0909090909',
          'role': 'admin',
        },
      };

      final authResult = AuthResultModel.fromJson(json);

      expect(authResult.token, equals('jwt_access_token_xyz_999'));
      expect(authResult.tokenType, equals('Bearer'));
      expect(authResult.user.id, equals(1));
      expect(authResult.user.fullname, equals('Admin User'));
      expect(authResult.user.email, equals('admin@carnow.vn'));
      expect(authResult.user.role, equals('admin'));
    });

    test('nên gán token_type mặc định Bearer khi trường này bị thiếu', () {
      final json = {
        'token': 'some_token',
        'user': {
          'id': 2,
          'fullname': 'Khách',
          'email': 'guest@carnow.vn',
          'phone': '0901112222',
        },
      };

      final authResult = AuthResultModel.fromJson(json);

      expect(authResult.tokenType, equals('Bearer'));
      expect(authResult.token, equals('some_token'));
    });
  });
}
