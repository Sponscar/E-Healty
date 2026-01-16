import 'package:e_healty/data/repositories/auth_repository.dart';
import 'package:e_healty/domain/entities/user.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    final user = await repository.register(
      email,
      password,
      name,
      phone,
    );

    return UserEntity(
      uid: user.uid,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      role: user.role,
    );
  }
}
