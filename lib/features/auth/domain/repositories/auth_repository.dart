import 'package:book_drive_car/features/auth/domain/entities/auth_result_entity.dart';
import 'package:book_drive_car/features/auth/domain/entities/register_request_entity.dart';

abstract class AuthRepository{
  Future<String> sendOtp(RegisterRequestEntity request);
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  });
  Future<AuthResultEntity> login(String email, String password);
}
