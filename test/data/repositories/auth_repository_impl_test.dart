import 'package:book_drive_car/features/auth/data/models/register_request_model.dart';
import 'package:book_drive_car/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:book_drive_car/features/auth/domain/entities/register_request_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';

class FakeRegisterRequestModel extends Fake implements RegisterRequestModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRegisterRequestModel());
  });

  late MockAuthRemoteDataSource mockRemoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource);
  });

  group('AuthRepositoryImpl - login', () {
    const email = 'user@example.com';
    const password = 'Password@123';

    test('nên trả về AuthResultEntity khi DataSource gọi đăng nhập thành công', () async {
      when(() => mockRemoteDataSource.login(email, password))
          .thenAnswer((_) async => testAuthResultModel);

      final result = await repository.login(email, password);

      expect(result, equals(testAuthResultModel));
      expect(result.token, equals('mock_jwt_token_123'));
      expect(result.user.email, equals('test@example.com'));
      verify(() => mockRemoteDataSource.login(email, password)).called(1);
    });

    test('nên ném ngoại lệ khi DataSource đăng nhập thất bại', () async {
      when(() => mockRemoteDataSource.login(email, password))
          .thenThrow(Exception('Sai mật khẩu'));

      expect(() => repository.login(email, password), throwsA(isA<Exception>()));
      verify(() => mockRemoteDataSource.login(email, password)).called(1);
    });
  });

  group('AuthRepositoryImpl - sendOtp & verifyOtp', () {
    final registerEntity = RegisterRequestEntity(
      fullname: 'Nguyễn Văn Test',
      email: 'test@carnow.vn',
      password: 'SecurePassword123!',
      phone: '0901234567',
      cccd: '001234567890',
      address: 'Hà Nội',
    );

    test('nên chuyển đổi Entity thành Model và trả về thông điệp OTP thành công', () async {
      when(() => mockRemoteDataSource.sendOtp(any()))
          .thenAnswer((_) async => 'Mã OTP đã được gửi');

      final result = await repository.sendOtp(registerEntity);

      expect(result, equals('Mã OTP đã được gửi'));
      verify(() => mockRemoteDataSource.sendOtp(any())).called(1);
    });

    test('nên truyền đúng tham số email và otpCode khi xác thực OTP', () async {
      when(() => mockRemoteDataSource.verifyOtp(email: 'test@carnow.vn', otpCode: '123456'))
          .thenAnswer((_) async => 'Xác thực OTP thành công');

      final result = await repository.verifyOtp(email: 'test@carnow.vn', otpCode: '123456');

      expect(result, equals('Xác thực OTP thành công'));
      verify(() => mockRemoteDataSource.verifyOtp(email: 'test@carnow.vn', otpCode: '123456')).called(1);
    });
  });
}
