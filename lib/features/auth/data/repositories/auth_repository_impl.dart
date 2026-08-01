import 'package:book_drive_car/features/auth/domain/entities/auth_result_entity.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/register_request_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/register_request_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> sendOtp(RegisterRequestEntity request) async {
    final model = RegisterRequestModel(
      fullname: request.fullname,
      email: request.email,
      password: request.password,
      phone: request.phone,
      cccd: request.cccd,
      address: request.address,
    );
    return await remoteDataSource.sendOtp(model);
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) {
    return remoteDataSource.verifyOtp(email: email, otpCode: otpCode);
  }

  @override
  Future<AuthResultEntity> login(String email, String password)async {
     return await remoteDataSource.login(email, password);
  }
}
