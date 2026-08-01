import 'package:injectable/injectable.dart';
import '../entities/add_vehicle_request_entity.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@injectable
class AddVehicle {
  final VehicleRepository repository;
  AddVehicle(this.repository);

  Future<VehicleEntity> call(AddVehicleRequestEntity request) async {
    return await repository.addVehicle(request);
  }
}