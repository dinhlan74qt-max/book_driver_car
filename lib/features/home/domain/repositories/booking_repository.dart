import '../entities/booking_entity.dart';
import '../entities/booking_request_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking(BookingRequestEntity request);
}