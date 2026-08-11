import 'package:book_drive_car/features/profile/domain/entities/address_entity.dart';

class VehicleEntity {
  final int id;
  final String vehicleName;
  final String vehicleType;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String vehicleRegistration; // thêm mới
  final int seatCount;
  final String fuelType;
  final String transmission;
  final double pricePerDay;
  final String status;
  final String description;
  final List<String> imageUrls;
  final AddressEntity address;
  final String? contractUrl;

  VehicleEntity({
    required this.id,
    required this.vehicleName,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.vehicleRegistration,
    required this.seatCount,
    required this.fuelType,
    required this.transmission,  // "MANUAL" (số sàn) / "AUTOMATIC" (số tự động)
    required this.pricePerDay,
    required this.status,
    required this.description,
    required this.imageUrls,
    required this.address,
    this.contractUrl,
  });
}
