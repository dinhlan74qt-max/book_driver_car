import 'package:injectable/injectable.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class Login {
  final AuthRepository repository;
  Login(this.repository);

  Future<AuthResultEntity> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
