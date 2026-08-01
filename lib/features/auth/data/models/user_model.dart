import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.fullname,
    required super.email,
    required super.phone,
    super.cccd,
    super.address,
    super.avatar,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    return UserModel(
      id: _toInt(json['id'] ?? json['userId'] ?? json['user_id']),
      fullname: json['fullname']?.toString() ??
          json['fullName']?.toString() ??
          '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      cccd: json['cccd']?.toString(),
      address: json['address']?.toString(),
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString() ?? 'user',
    );
  }
}
