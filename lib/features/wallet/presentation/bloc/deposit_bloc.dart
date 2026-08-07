import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/deposit.dart';
import 'deposit_event.dart';
import 'deposit_state.dart';

@injectable
class DepositBloc extends Bloc<DepositEvent, DepositState> {
  final Deposit depositUseCase;

  DepositBloc(this.depositUseCase) : super(DepositInitial()) {
    on<DepositSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(DepositSubmitted event, Emitter<DepositState> emit) async {
    emit(DepositLoading());
    try {
      final result = await depositUseCase(event.amount);
      emit(DepositSuccess(result));
    } catch (e) {
      debugPrint('[DepositBloc][DepositSubmitted] Error: $e');
      emit(DepositFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
