import 'package:e_healty/domain/entities/user.dart';
import 'package:e_healty/domain/usecase/auth/login.dart';
import 'package:e_healty/domain/usecase/auth/logout.dart';
import 'package:e_healty/domain/usecase/auth/register.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {

  late final LoginUseCase _login;
  late final RegisterUseCase _register;
  late final LogoutUseCase _logout;

  AuthProvider() {
    final repo = AuthRepository(FirebaseAuthDatasource());
    _login = LoginUseCase(repo);
    _register = RegisterUseCase(repo);
    _logout = LogoutUseCase(repo);
  }

  bool _isLoading = false;
  String? _errorMessage;
  UserEntity? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserEntity? get user => _user;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _login(email, password);

    } catch (e) {
      _errorMessage = "Email atau password salah";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _register(
        email,
        password,
        name,
        phone,
      );

    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logout();
    _user = null;
    notifyListeners();
  }
}
