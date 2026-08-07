import 'package:book_drive_car/features/home/domain/usercases/create_booking.dart';
import 'package:book_drive_car/features/home/presentation/bloc/booking_event.dart';
import 'package:book_drive_car/features/home/presentation/bloc/booking_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBooking createBookingUseCase;

  BookingBloc(this.createBookingUseCase) : super(BookingInitial()) {
    on<CreateBookingSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreateBookingSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final booking = await createBookingUseCase(event.request);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
