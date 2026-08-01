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
      id: json['id'],
      vehicleName: json['vehicleName'],
      vehicleType: json['vehicleType'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      licensePlate: json['licensePlate'],
      vehicleRegistration: json['vehicleRegistration'] ?? '', // thêm mới
      seatCount: json['seatCount'],
      fuelType: json['fuelType'],
      transmission: json['transmission'] ?? '',
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      status: json['status'],
      description: json['description'],
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : AddressModel(addressDetail: '', ward: '', district: '', city: ''),
    );
  }
}