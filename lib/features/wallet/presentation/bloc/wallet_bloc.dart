import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc(this.walletRepository) : super(WalletInitial()) {
    on<WalletRequested>(_onRequested);
  }

  Future<void> _onRequested(
    WalletRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final wallet = await walletRepository.getMyWallet();
      List<WalletTransactionEntity> history = const [];
      try {
        history = await walletRepository.getMyWalletHistory();
      } catch (historyError) {
        debugPrint('[WalletBloc][WalletRequested][History] Error: $historyError');
      }
      emit(WalletLoaded(wallet, history));
    } catch (e) {
      debugPrint('[WalletBloc][WalletRequested] Error: $e');
      emit(WalletFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
