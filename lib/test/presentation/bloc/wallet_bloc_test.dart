import 'package:book_drive_car/features/wallet/domain/entities/wallet_entity.dart';
import 'package:book_drive_car/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:book_drive_car/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late MockWalletRepository mockWalletRepository;
  late WalletBloc walletBloc;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    walletBloc = WalletBloc(mockWalletRepository);
  });

  tearDown(() {
    walletBloc.close();
  });

  final testWallet = WalletEntity(id: 1, balance: 5000000);
  final List<WalletTransactionEntity> testHistory = [
    WalletTransactionEntity(
      id: 101,
      amount: 1000000,
      transactionType: 'DEPOSIT',
      createdAt: DateTime(2026, 11, 10),
      description: 'Nạp tiền VietQR',
    ),
  ];

  test('trạng thái ban đầu phải là WalletInitial', () {
    expect(walletBloc.state, isA<WalletInitial>());
  });

  test('nên phát ra [WalletLoading, WalletLoaded] khi lấy ví và lịch sử thành công', () async {
    when(() => mockWalletRepository.getMyWallet()).thenAnswer((_) async => testWallet);
    when(() => mockWalletRepository.getMyWalletHistory()).thenAnswer((_) async => testHistory);

    final expectedStates = [
      isA<WalletLoading>(),
      isA<WalletLoaded>()
          .having((s) => s.wallet.balance, 'balance', 5000000)
          .having((s) => s.history.length, 'history length', 1),
    ];

    expectLater(walletBloc.stream, emitsInOrder(expectedStates));

    walletBloc.add(WalletRequested());
  });

  test('nên phát ra [WalletLoading, WalletLoaded] với history rỗng khi getMyWalletHistory lỗi', () async {
    when(() => mockWalletRepository.getMyWallet()).thenAnswer((_) async => testWallet);
    when(() => mockWalletRepository.getMyWalletHistory()).thenThrow(Exception('Lỗi mạng khi tải lịch sử'));

    final expectedStates = [
      isA<WalletLoading>(),
      isA<WalletLoaded>()
          .having((s) => s.wallet.balance, 'balance', 5000000)
          .having((s) => s.history, 'history', isEmpty),
    ];

    expectLater(walletBloc.stream, emitsInOrder(expectedStates));

    walletBloc.add(WalletRequested());
  });

  test('nên phát ra [WalletLoading, WalletFailure] khi getMyWallet ném ngoại lệ', () async {
    when(() => mockWalletRepository.getMyWallet()).thenThrow(Exception('Không thể kết nối máy chủ'));

    final expectedStates = [
      isA<WalletLoading>(),
      isA<WalletFailure>().having((s) => s.error, 'error', 'Không thể kết nối máy chủ'),
    ];

    expectLater(walletBloc.stream, emitsInOrder(expectedStates));

    walletBloc.add(WalletRequested());
  });
}
