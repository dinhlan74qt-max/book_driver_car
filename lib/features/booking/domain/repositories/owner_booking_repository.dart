import 'package:book_drive_car/features/booking/domain/entities/owner_booking_entity.dart';

abstract class OwnerBookingRepository {
  Future<List<OwnerBookingEntity>> getOwnerBookings();
  Future<OwnerBookingEntity> approveBooking(String id);
  Future<OwnerBookingEntity> rejectBooking(String id, {String? reason});
}
