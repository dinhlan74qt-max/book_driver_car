import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';

abstract class HomeRepository {
  Future<List<CarEntity>> getCars();
  
  // Tạm thời nhận filter map hoặc các params rời rạc để tránh import widget từ tầng Presentation
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
  });

  Future<List<CarEntity>> searchCarsByCity(String cityName);

  Future<CarEntity> getCarDetail(String id);
}
