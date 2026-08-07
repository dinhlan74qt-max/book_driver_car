import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/wallet_transaction_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletEntity wallet;
  final List<WalletTransactionEntity> history;

  const WalletLoaded(this.wallet, this.history);

  @override
  List<Object?> get props => [wallet, history];
}

class WalletFailure extends WalletState {
  final String error;
  const WalletFailure(this.error);

  @override
  List<Object?> get props => [error];
}
