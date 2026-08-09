import 'package:book_drive_car/features/profile/data/datasources/owner_booking_remote_data_source.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/profile/domain/repositories/owner_booking_repository.dart';
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
  Future<OwnerBookingEntity> updateBookingStatus({
    required String id,
    required String status,
    String? reason,
  }) {
    return remoteDataSource.updateBookingStatus(id: id, status: status, reason: reason);
  }
}
