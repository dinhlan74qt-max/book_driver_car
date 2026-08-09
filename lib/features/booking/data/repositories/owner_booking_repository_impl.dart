import 'package:book_drive_car/features/booking/data/datasources/owner_booking_remote_data_source.dart';
import 'package:book_drive_car/features/booking/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/booking/domain/repositories/owner_booking_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OwnerBookingRepository)
class OwnerBookingRepositoryImpl implements OwnerBookingRepository {
  final OwnerBookingRemoteDataSource remoteDataSource;

  OwnerBookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OwnerBookingEntity>> getOwnerBookings() {
    return remoteDataSource.getOwnerBookings();
  }

  @override
  Future<OwnerBookingEntity> approveBooking(String id) {
    return remoteDataSource.approveBooking(id);
  }

  @override
  Future<OwnerBookingEntity> rejectBooking(String id, {String? reason}) {
    return remoteDataSource.rejectBooking(id, reason: reason);
  }
}
