import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  AddressModel({
    required super.addressDetail,
    required super.ward,
    required super.district,
    required super.city,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressDetail: json['addressDetail'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "addressDetail": addressDetail,
      "ward": ward,
      "district": district,
      "city": city,
    };
  }
}