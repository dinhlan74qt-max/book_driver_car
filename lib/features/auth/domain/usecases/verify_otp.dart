import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<String> call({
    required String email,
    required String otpCode,
  }) async {
    return await repository.verifyOtp(email: email, otpCode: otpCode);
  }
}

