import 'rental_vehicle_address_entity.dart';

class RentalVehicleEntity {
  final int id;
  final String vehicleName;
  final String vehicleType;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String? vehicleRegistration;
  final int seatCount;
  final String fuelType;
  final String transmission;
  final int pricePerDay;
  final String status;
  final String description;
  final List<String> imageUrls;
  final RentalVehicleAddressEntity address;
  final double distance;
  final String? ownerName;
  final String? ownerPhone;

  RentalVehicleEntity({
    required this.id,
    required this.vehicleName,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.vehicleRegistration,
    required this.seatCount,
    required this.fuelType,
    required this.transmission,
    required this.pricePerDay,
    required this.status,
    required this.description,
    required this.imageUrls,
    required this.address,
    required this.distance,
    this.ownerName,
    this.ownerPhone,
  });
}
