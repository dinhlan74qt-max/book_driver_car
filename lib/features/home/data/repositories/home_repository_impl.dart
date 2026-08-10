import 'package:book_drive_car/features/home/data/datasources/home_remote_data_source.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/domain/repositories/home_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CarEntity>> getCars() async {
    return await remoteDataSource.getCars();
  }

  @override
  Future<CarEntity> getCarDetail(String id) async {
    return await remoteDataSource.getCarDetail(id);
  }

  @override
  Future<List<CarEntity>> searchCars({
    String? locationMode,
    String? locationLabel,
    double? latitude,
    double? longitude,
    String? vehicleType,
    String? brand,
    String? model,
  }) async {
    final params = <String, dynamic>{};
    if (brand != null && brand.isNotEmpty) params['brand'] = brand;
    if (vehicleType != null && vehicleType.isNotEmpty) params['vehicleType'] = vehicleType;
    if (model != null && model.isNotEmpty) params['model'] = model;
    if (latitude != null && longitude != null) {
      params['lat'] = latitude.toString();
      params['lng'] = longitude.toString();
    }
    return await remoteDataSource.searchCars(params);
  }

  @override
  Future<List<CarEntity>> searchCarsByCity(String cityName) async {
    return await remoteDataSource.searchCarsByCity(cityName);
  }
}
