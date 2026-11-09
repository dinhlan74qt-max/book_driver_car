import 'package:book_drive_car/features/auth/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';

void main() {
  late MockAuthRepository mockRepository;
  late Login loginUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = Login(mockRepository);
  });

  const email = 'user@example.com';
  const password = 'Password@123';

  test('nên gọi login từ repository và trả về AuthResultEntity', () async {
    when(() => mockRepository.login(email, password))
        .thenAnswer((_) async => testAuthResultEntity);

    final result = await loginUseCase(email, password);

    expect(result, equals(testAuthResultEntity));
    expect(result.token, equals('mock_jwt_token_123'));
    verify(() => mockRepository.login(email, password)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('nên chuyển tiếp exception khi repository thất bại', () async {
    when(() => mockRepository.login(email, password))
        .thenThrow(Exception('Tài khoản không tồn tại'));

    expect(() => loginUseCase(email, password), throwsA(isA<Exception>()));
    verify(() => mockRepository.login(email, password)).called(1);
  });
}
