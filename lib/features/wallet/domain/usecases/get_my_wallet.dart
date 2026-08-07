import 'package:injectable/injectable.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

@injectable
class GetMyWallet {
  final WalletRepository repository;
  GetMyWallet(this.repository);

  Future<WalletEntity> call() async {
    return await repository.getMyWallet();
  }
}