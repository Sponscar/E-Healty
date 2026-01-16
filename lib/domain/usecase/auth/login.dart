import 'package:e_healty/data/repositories/auth_repository.dart';
import 'package:e_healty/domain/entities/user.dart';


class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) async {
    final user = await repository.login(email, password);

    return UserEntity(
      uid: user.uid,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      role: user.role,
    );
  }
}
