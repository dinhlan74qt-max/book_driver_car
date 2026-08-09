import '../../domain/entities/rental_vehicle_address_entity.dart';

class RentalVehicleAddressModel extends RentalVehicleAddressEntity {
  RentalVehicleAddressModel({
    required super.addressDetail,
    required super.ward,
    required super.district,
    required super.city,
    required super.latitude,
    required super.longitude,
  });

  factory RentalVehicleAddressModel.fromJson(Map<String, dynamic> json) {
    return RentalVehicleAddressModel(
      addressDetail: json['addressDetail'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}
