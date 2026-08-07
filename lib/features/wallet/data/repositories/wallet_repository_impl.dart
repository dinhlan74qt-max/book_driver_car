import 'package:injectable/injectable.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/deposit_result_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<WalletEntity> getMyWallet() async {
    return await remoteDataSource.getMyWallet();
  }

  @override
  Future<DepositResultEntity> deposit(int amount) async {
    return await remoteDataSource.deposit(amount);
  }
}