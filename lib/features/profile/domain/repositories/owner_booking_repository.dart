import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';

abstract class OwnerBookingRepository {
  Future<List<OwnerBookingEntity>> getOwnerBookings();
  Future<OwnerBookingEntity> updateBookingStatus({required String id, required String status, String? reason});
}
