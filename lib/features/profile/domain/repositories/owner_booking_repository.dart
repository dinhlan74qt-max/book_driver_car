import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'dart:typed_data';

abstract class OwnerBookingRepository {
  Future<List<OwnerBookingEntity>> getOwnerBookings();
  Future<OwnerBookingEntity> updateBookingStatus({required String id, required String status, String? reason});
  Future<OwnerBookingEntity> approveBookingWithContract({
    required String id,
    required Uint8List contractPdfBytes,
    required String contractPdfFileName,
  });
}
