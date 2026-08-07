import '../entities/wallet_entity.dart';
import '../entities/deposit_result_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getMyWallet();
  Future<DepositResultEntity> deposit(int amount);
}