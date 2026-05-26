import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_healty/data/models/user_model.dart';
import 'package:e_healty/domain/entities/user.dart';
import 'package:e_healty/domain/usecase/auth/login.dart';
import 'package:e_healty/domain/usecase/auth/logout.dart';
import 'package:e_healty/domain/usecase/auth/register.dart';
import 'package:e_healty/domain/usecase/auth/update_photo.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {

  late final LoginUseCase _login;
  late final RegisterUseCase _register;
  late final LogoutUseCase _logout;
  late final UpdatePhotoUseCase _updatePhoto;
  late final FirebaseAuthDatasource _datasource;

  // fungsi loadUser bisa di-override saat testing
  late final Future<UserEntity?> Function(String uid) _loadUserFn;

  // Constructor normal (production)
  AuthProvider() {
    final ds = FirebaseAuthDatasource();
    final repo = AuthRepository(ds);
    _login = LoginUseCase(repo);
    _register = RegisterUseCase(repo);
    _logout = LogoutUseCase(repo);
    _updatePhoto = UpdatePhotoUseCase(repo);
    _datasource = ds;
    _loadUserFn = _loadUserFromFirestore;
  }

  // Constructor khusus testing
  AuthProvider.forTest({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required UpdatePhotoUseCase updatePhoto,
    required FirebaseAuthDatasource datasource,
    Future<UserEntity?> Function(String uid)? loadUserFn,
  }) {
    _login = login;
    _register = register;
    _logout = logout;
    _updatePhoto = updatePhoto;
    _datasource = datasource;
    _loadUserFn = loadUserFn ?? _loadUserFromFirestore;
  }

  bool _isLoading = false;
  String? _errorMessage;
  UserEntity? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserEntity? get user => _user;

  // loadUser internal (production)
  Future<UserEntity?> _loadUserFromFirestore(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _login(email, password);
      final loaded = await _loadUserFn(_user!.uid);
      if (loaded != null) _user = loaded;

    } catch (e) {
      _errorMessage = "Email atau password salah";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
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

      _user = await _register(email, password, name, phone);

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

  Future<void> updatePhotoBase64(String base64) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_user == null) {
        throw Exception("User tidak ditemukan");
      }

      await _datasource.updatePhotoBase64(
        uid: _user!.uid,
        base64: base64,
      );

      final loaded = await _loadUserFn(_user!.uid);
      if (loaded != null) _user = loaded;

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_user == null) {
        throw Exception("User tidak ditemukan");
      }

      await _datasource.updateUserProfile(
        uid: _user!.uid,
        name: name,
        phone: phone,
      );

      _user = _user!.copyWith(
        name: name,
        phoneNumber: phone,
        photoBase64: _user!.photoBase64,
      );

      notifyListeners();

    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser(String uid) async {
    final loaded = await _loadUserFn(uid);
    if (loaded != null) {
      _user = loaded;
      notifyListeners();
    }
  }
}