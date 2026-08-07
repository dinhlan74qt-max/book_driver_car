import 'package:injectable/injectable.dart';

import '../../domain/entities/add_vehicle_request_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_data_source.dart';

@LazySingleton(as: VehicleRepository)
class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl(this.remoteDataSource);

  @override
  Future<VehicleEntity> addVehicle(AddVehicleRequestEntity request) async {
    return await remoteDataSource.addVehicle(request);
  }

  @override
  Future<List<VehicleEntity>> getMyVehicles() async {
    return await remoteDataSource.getMyVehicles();
  }
}
