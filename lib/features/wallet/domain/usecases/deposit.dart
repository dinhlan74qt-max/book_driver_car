import 'package:injectable/injectable.dart';
import '../entities/deposit_result_entity.dart';
import '../repositories/wallet_repository.dart';

@injectable
class Deposit {
  final WalletRepository repository;
  Deposit(this.repository);

  Future<DepositResultEntity> call(int amount) async {
    return await repository.deposit(amount);
  }
}