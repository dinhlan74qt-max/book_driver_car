import 'dart:io';
import 'address_entity.dart';

class AddVehicleRequestEntity {
  final String vehicleName;
  final String vehicleType;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final File vehicleRegistration;
  final int seatCount;
  final String fuelType;
  final String transmission;
  final double pricePerDay;
  final String description;
  final AddressEntity address;
  final List<File> images;

  AddVehicleRequestEntity({
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
    required this.transmission,
    required this.pricePerDay,
    required this.description,
    required this.address,
    required this.images,
  });
}