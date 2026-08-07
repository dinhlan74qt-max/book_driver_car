import 'package:injectable/injectable.dart';

import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@injectable
class GetMyVehicles {
  final VehicleRepository repository;

  GetMyVehicles(this.repository);

  Future<List<VehicleEntity>> call() async {
    return await repository.getMyVehicles();
  }
}
