import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/withdraw.dart';
import 'withdraw_event.dart';
import 'withdraw_state.dart';

@injectable
class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  final Withdraw withdrawUseCase;

  WithdrawBloc(this.withdrawUseCase) : super(WithdrawInitial()) {
    on<WithdrawSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    WithdrawSubmitted event,
    Emitter<WithdrawState> emit,
  ) async {
    emit(WithdrawLoading());
    try {
      final message = await withdrawUseCase(event.request);
      emit(WithdrawSuccess(message));
    } catch (e) {
      emit(WithdrawFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
