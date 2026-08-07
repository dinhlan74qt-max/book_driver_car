import '../entities/wallet_entity.dart';
import '../entities/deposit_result_entity.dart';
import '../entities/wallet_transaction_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getMyWallet();
  Future<DepositResultEntity> deposit(int amount);
  Future<List<WalletTransactionEntity>> getMyWalletHistory();
}
