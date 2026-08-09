import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_request_entity.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class CreateBookingSubmitted extends BookingEvent {
  final BookingRequestEntity request;
  const CreateBookingSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}
