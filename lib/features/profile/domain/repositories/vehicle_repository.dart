import '../entities/add_vehicle_request_entity.dart';
import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<VehicleEntity> addVehicle(AddVehicleRequestEntity request);
  Future<List<VehicleEntity>> getMyVehicles();
}
