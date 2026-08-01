import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/send_otp.dart';
import 'send_otp_event.dart';
import 'send_otp_state.dart';
@injectable
class SendOtpBloc extends Bloc<SendOtpEvent, SendOtpState> {
  final SendOtp sendOtpUseCase;

  SendOtpBloc(this.sendOtpUseCase) : super(SendOtpInitial()) {
    on<SendOtpSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    SendOtpSubmitted event,
    Emitter<SendOtpState> emit,
  ) async {
    emit(SendOtpLoading());
    try {
      final message = await sendOtpUseCase.call(event.request);
      emit(SendOtpSuccess(message));
    } catch (e) {
      emit(SendOtpFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}