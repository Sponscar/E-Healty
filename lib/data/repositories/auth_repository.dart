import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuthDatasource datasource;

  AuthRepository(this.datasource);

  Future<UserModel> login(String email, String password) {
    return datasource.login(email, password);
  }

  Future<UserModel> register(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) {
    return datasource.register(email, password, name, phoneNumber);
  }

  Future logout() {
    return datasource.logout();
  }
}
