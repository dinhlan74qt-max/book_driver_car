import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_my_wallet.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetMyWallet getMyWalletUseCase;

  WalletBloc(this.getMyWalletUseCase) : super(WalletInitial()) {
    on<WalletRequested>(_onRequested);
  }

  Future<void> _onRequested(WalletRequested event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final wallet = await getMyWalletUseCase();
      emit(WalletLoaded(wallet));
    } catch (e) {
      debugPrint('[WalletBloc][WalletRequested] Error: $e');
      emit(WalletFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
