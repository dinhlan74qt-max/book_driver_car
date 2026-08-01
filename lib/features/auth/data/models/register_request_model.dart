import '../../domain/entities/register_request_entity.dart';

class RegisterRequestModel extends RegisterRequestEntity {
  RegisterRequestModel({
    required super.fullname,
    required super.email,
    required super.password,
    required super.phone,
    required super.cccd,
    required super.address,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullname": fullname,
      "email": email,
      "password": password,
      "phone": phone,
      "cccd": cccd,
      "address": address,
    };
  }
}