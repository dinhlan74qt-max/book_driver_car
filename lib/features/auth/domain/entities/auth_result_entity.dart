import 'user_entity.dart';

class AuthResultEntity {
  final String token;
  final String tokenType;
  final UserEntity user;

  AuthResultEntity({
    required this.token,
    required this.tokenType,
    required this.user,
  });
}