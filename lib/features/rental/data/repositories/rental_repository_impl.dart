import 'package:book_drive_car/features/rental/data/datasources/rental_remote_data_source.dart';
import 'package:book_drive_car/features/rental/domain/entities/rental_list_item_entity.dart';
import 'package:book_drive_car/features/rental/domain/repositories/rental_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RentalRepository)
class RentalRepositoryImpl implements RentalRepository {
  final RentalRemoteDataSource remoteDataSource;
  RentalRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RentalListItemEntity>> getRenterBookings() async {
    return await remoteDataSource.getRenterBookings();
  }
}
