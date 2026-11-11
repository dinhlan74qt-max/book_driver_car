import 'package:book_drive_car/features/auth/presentation/bloc/login_bloc.dart';
import 'package:book_drive_car/features/auth/presentation/bloc/login_event.dart';
import 'package:book_drive_car/features/auth/presentation/bloc/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(testUserEntity);
  });

  late MockLoginUseCase mockLoginUseCase;
  late MockUserLocalStorage mockUserLocalStorage;
  late LoginBloc loginBloc;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockUserLocalStorage = MockUserLocalStorage();
    loginBloc = LoginBloc(mockLoginUseCase, mockUserLocalStorage);
  });

  tearDown(() {
    loginBloc.close();
  });

  const email = 'bomn515@gmail.com';
  const password = 'Lan280650@';

  test('trạng thái ban đầu phải là LoginInitial', () {
    expect(loginBloc.state, isA<LoginInitial>());
  });

  test(
    'nên phát ra [LoginLoading, LoginSuccess] và lưu session khi đăng nhập thành công',
    () async {
      when(
        () => mockLoginUseCase(email, password),
      ).thenAnswer((_) async => testAuthResultEntity);
      when(
        () => mockUserLocalStorage.saveSession(
          token: any(named: 'token'),
          tokenType: any(named: 'tokenType'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async {});

      final expectedStates = [
        isA<LoginLoading>(),
        isA<LoginSuccess>().having(
          (s) => s.result.token,
          'token',
          'mock_jwt_token_123',
        ),
      ];

      expectLater(loginBloc.stream, emitsInOrder(expectedStates));

      loginBloc.add(const LoginSubmitted(email: email, password: password));
    },
  );

  test(
    'nên phát ra [LoginLoading, LoginFailure] khi usecase ném ngoại lệ',
    () async {
      when(
        () => mockLoginUseCase(email, password),
      ).thenThrow(Exception('Sai mật khẩu hoặc email không tồn tại'));

      final expectedStates = [
        isA<LoginLoading>(),
        isA<LoginFailure>().having(
          (s) => s.error,
          'error',
          contains('Sai mật khẩu hoặc email không tồn tại'),
        ),
      ];

      expectLater(loginBloc.stream, emitsInOrder(expectedStates));

      loginBloc.add(const LoginSubmitted(email: email, password: password));
    },
  );
}
