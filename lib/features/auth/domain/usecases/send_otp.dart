import 'package:injectable/injectable.dart';

import '../entities/register_request_entity.dart';
import '../repositories/auth_repository.dart';
@injectable
class SendOtp {
  final AuthRepository repository;
  SendOtp(this.repository);

  Future<String> call(RegisterRequestEntity request) async {
    return await repository.sendOtp(request);
  }
}