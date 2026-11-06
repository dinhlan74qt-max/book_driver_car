import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_request_entity.dart';
import '../../domain/entities/verified_user_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_availability_model.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<BookingEntity> createBooking(BookingRequestEntity request) {
    return remoteDataSource.createBooking(request);
  }

  @override
  Future<List<BookingAvailabilityModel>> getBookedRanges(int vehicleId) {
    return remoteDataSource.getBookedRanges(vehicleId);
  }

  @override
  Future<BookingEntity> updateBookingStatus({
    required int id,
    required String status,
    String? reason,
  }) {
    return remoteDataSource.updateBookingStatus(
      id: id,
      status: status,
      reason: reason,
    );
  }

  @override
  Future<VerifiedUserEntity> checkVerified() {
    return remoteDataSource.checkVerified();
  }

  @override
  Future<String> uploadContractPdf({
    required Uint8List pdfBytes,
    required String fileName,
  }) {
    return remoteDataSource.uploadContractPdf(
      pdfBytes: pdfBytes,
      fileName: fileName,
    );
  }
}

