import 'dart:typed_data';
import '../entities/booking_entity.dart';
import '../entities/booking_request_entity.dart';
import '../entities/verified_user_entity.dart';
import '../../data/models/booking_availability_model.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking(BookingRequestEntity request);
  Future<List<BookingAvailabilityModel>> getBookedRanges(int vehicleId);
  Future<BookingEntity> updateBookingStatus({
    required int id,
    required String status,
    String? reason,
  });
  Future<VerifiedUserEntity> checkVerified();
  Future<String> uploadContractPdf({
    required Uint8List pdfBytes,
    required String fileName,
  });
}
