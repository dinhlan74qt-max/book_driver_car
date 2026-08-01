import 'dart:convert';
import 'package:book_drive_car/features/auth/data/models/auth_result_model.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp(RegisterRequestModel request);
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  });
   Future<AuthResultModel> login(String email, String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<String> sendOtp(RegisterRequestModel request) async {
    final response = await client.post(
      Uri.parse(ApiConstants.sendOtp),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["message"] as String;
    } else {
      throw Exception(data["message"] ?? "Gửi OTP thất bại");
    }
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await client.post(
      Uri.parse(ApiConstants.verifyOtp),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otpCode": otpCode,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["message"] as String;
    } else {
      throw Exception(data["message"] ?? "Xác thực OTP thất bại");
    }
  }
  
  @override
  Future<AuthResultModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse(ApiConstants.login), 
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AuthResultModel.fromJson(data["data"]);
    } else {
      throw Exception(data["message"] ?? "Đăng nhập thất bại");
    }
  }
}
