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
    int? minPrice,
    int? maxPrice,
    int? minSeats,
    int? maxSeats,
    String? city,
  }) async {
    final params = <String, dynamic>{};

    final effectiveCity = (city != null && city.trim().isNotEmpty)
        ? city.trim()
        : (locationLabel != null && locationLabel.trim().isNotEmpty
            ? locationLabel.trim()
            : null);

    if (effectiveCity != null &&
        effectiveCity != 'Tất cả' &&
        !effectiveCity.contains('Vị trí hiện tại')) {
      params['city'] = effectiveCity;
    }

    if (brand != null && brand.isNotEmpty && brand != 'Tất cả') {
      params['brand'] = brand.trim();
    }

    if (model != null && model.isNotEmpty && model != 'Tất cả') {
      params['model'] = model.trim();
    }

    int? effectiveMinSeats = minSeats;
    int? effectiveMaxSeats = maxSeats;

    if (effectiveMinSeats == null &&
        effectiveMaxSeats == null &&
        vehicleType != null) {
      if (vehicleType.contains('4 chỗ')) {
        effectiveMinSeats = 4;
        effectiveMaxSeats = 4;
      } else if (vehicleType.contains('5 chỗ')) {
        effectiveMinSeats = 5;
        effectiveMaxSeats = 5;
      } else if (vehicleType.contains('7 chỗ')) {
        effectiveMinSeats = 7;
        effectiveMaxSeats = 7;
      }
    }

    if (effectiveMinSeats != null) params['minSeats'] = effectiveMinSeats;
    if (effectiveMaxSeats != null) params['maxSeats'] = effectiveMaxSeats;

    if (minPrice != null && minPrice > 0) params['minPrice'] = minPrice;
    if (maxPrice != null && maxPrice > 0) params['maxPrice'] = maxPrice;

    return await remoteDataSource.searchCars(params);
  }

  @override
  Future<List<CarEntity>> searchCarsByCity(String cityName) async {
    return await remoteDataSource.searchCarsByCity(cityName);
  }
}
