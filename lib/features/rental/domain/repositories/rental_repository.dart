import '../entities/rental_list_item_entity.dart';

abstract class RentalRepository {
  Future<List<RentalListItemEntity>> getRenterBookings();
  Future<void> cancelBooking(int bookingId, {String? reason});
}
