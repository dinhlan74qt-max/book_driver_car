import 'package:injectable/injectable.dart';
import '../entities/withdraw_request_entity.dart';
import '../repositories/wallet_repository.dart';

@injectable
class Withdraw {
  final WalletRepository repository;
  Withdraw(this.repository);

  Future<String> call(WithdrawRequestEntity request) async {
    return await repository.withdraw(request);
  }
}