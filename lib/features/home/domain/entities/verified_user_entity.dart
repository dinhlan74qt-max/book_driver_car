import 'package:book_drive_car/features/profile/domain/entities/address_entity.dart';

class VerifiedUserEntity {
  final String fullname;
  final String email;
  final String phone;
  final String? cccd;
  final AddressEntity? address;

  const VerifiedUserEntity({
    required this.fullname,
    required this.email,
    required this.phone,
    this.cccd,
    this.address,
  });

  String get addressText {
    final value = address;
    if (value == null) return '';
    return [
      value.addressDetail,
      value.ward,
      value.district,
      value.city,
    ].where((item) => item.trim().isNotEmpty).join(', ');
  }
}
