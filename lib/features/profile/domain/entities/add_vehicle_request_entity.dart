import 'dart:io';
import 'dart:typed_data';
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
  final String? contractUrl;
  final Uint8List? contractPdfBytes;

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
    this.contractUrl,
    this.contractPdfBytes,
  });

  AddVehicleRequestEntity copyWith({
    String? vehicleName,
    String? vehicleType,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    File? vehicleRegistration,
    int? seatCount,
    String? fuelType,
    String? transmission,
    double? pricePerDay,
    String? description,
    AddressEntity? address,
    List<File>? images,
    String? contractUrl,
    Uint8List? contractPdfBytes,
  }) {
    return AddVehicleRequestEntity(
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      seatCount: seatCount ?? this.seatCount,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      description: description ?? this.description,
      address: address ?? this.address,
      images: images ?? this.images,
      contractUrl: contractUrl ?? this.contractUrl,
      contractPdfBytes: contractPdfBytes ?? this.contractPdfBytes,
    );
  }
}
