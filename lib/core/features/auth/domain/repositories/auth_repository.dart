import 'package:book_drive_car/core/features/auth/domain/entities/register_request_entity.dart';

abstract class AuthRepository{
  Future<String> sendOtp(RegisterRequestEntity request);
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  });
}
