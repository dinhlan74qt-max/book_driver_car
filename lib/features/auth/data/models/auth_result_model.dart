import '../../domain/entities/auth_result_entity.dart';
import 'user_model.dart';

class AuthResultModel extends AuthResultEntity {
  AuthResultModel({
    required super.token,
    required super.tokenType,
    required super.user,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final userJson = rawUser is Map
        ? Map<String, dynamic>.from(rawUser)
        : <String, dynamic>{};

    return AuthResultModel(
      token: json['token']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ??
          json['token_type']?.toString() ??
          'Bearer',
      user: UserModel.fromJson(userJson),
    );
  }
}
