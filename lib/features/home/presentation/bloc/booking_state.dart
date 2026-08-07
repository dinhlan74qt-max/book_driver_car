import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_entity.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final BookingEntity booking;
  const BookingSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingFailure extends BookingState {
  final String error;
  const BookingFailure(this.error);

  @override
  List<Object?> get props => [error];
}
