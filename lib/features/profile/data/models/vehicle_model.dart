import 'package:book_drive_car/features/profile/data/models/address_model.dart';

import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  VehicleModel({
    required super.id,
    required super.vehicleName,
    required super.vehicleType,
    required super.brand,
    required super.model,
    required super.year,
    required super.color,
    required super.licensePlate,
    required super.vehicleRegistration,
    required super.seatCount,
    required super.fuelType,
    required super.transmission,
    required super.pricePerDay,
    required super.status,
    required super.description,
    required super.imageUrls,
    required super.address,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      vehicleName: json['vehicleName'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      color: json['color'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      vehicleRegistration: json['vehicleRegistration'] ?? '',
      seatCount: (json['seatCount'] as num?)?.toInt() ?? 0,
      fuelType: json['fuelType'] ?? '',
      transmission: json['transmission'] ?? 'Tự động',
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'AVAILABLE',
      description: json['description'] ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : AddressModel(addressDetail: '', ward: '', district: '', city: ''),
    );
  }
}
