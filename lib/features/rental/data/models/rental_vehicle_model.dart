import '../../domain/entities/rental_vehicle_entity.dart';
import 'rental_vehicle_address_model.dart';

class RentalVehicleModel extends RentalVehicleEntity {
  RentalVehicleModel({
    required super.id,
    required super.vehicleName,
    required super.vehicleType,
    required super.brand,
    required super.model,
    required super.year,
    required super.color,
    required super.licensePlate,
    super.vehicleRegistration,
    required super.seatCount,
    required super.fuelType,
    required super.transmission,
    required super.pricePerDay,
    required super.status,
    required super.description,
    required super.imageUrls,
    required super.address,
    required super.distance,
    super.ownerName,
    super.ownerPhone,
  });

  factory RentalVehicleModel.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] is Map
        ? Map<String, dynamic>.from(json['address'] as Map)
        : <String, dynamic>{};
    final ownerJson = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};

    return RentalVehicleModel(
      id: json['id'] as int? ?? 0,
      vehicleName: json['vehicleName'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] as int? ?? 0,
      color: json['color'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      vehicleRegistration: json['vehicleRegistration'], // có thể null
      seatCount: json['seatCount'] as int? ?? 0,
      fuelType: json['fuelType'] ?? '',
      transmission: json['transmission'] ?? '',
      pricePerDay: (json['pricePerDay'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      address: RentalVehicleAddressModel.fromJson(addressJson),
      // lưu ý: backend trả field tên "Distance" viết hoa chữ D
      distance: (json['Distance'] as num?)?.toDouble() ?? 0,
      ownerName: ownerJson['fullname']?.toString(),
      ownerPhone: ownerJson['phone']?.toString(),
    );
  }
}
