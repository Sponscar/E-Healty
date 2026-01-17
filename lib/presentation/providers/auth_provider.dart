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

  AuthProvider() {
    final repo = AuthRepository(FirebaseAuthDatasource());
    _login = LoginUseCase(repo);
    _register = RegisterUseCase(repo);
    _logout = LogoutUseCase(repo);
    _updatePhoto = UpdatePhotoUseCase(repo);
  }

  bool _isLoading = false;
  String? _errorMessage;
  UserEntity? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserEntity? get user => _user;

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _login(email, password);

      // 🔥 WAJIB: ambil ulang data terbaru termasuk photoPath
      await loadUser(_user!.uid);

    } catch (e) {
      _errorMessage = "Email atau password salah";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= REGISTER =================
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

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _logout();
    _user = null;
    notifyListeners();
  }

 // ================= UPDATE FOTO =================
Future<void> updatePhotoBase64(String base64) async {
  try {
    _isLoading = true;
    notifyListeners();

    if (_user == null) {
      throw Exception("User tidak ditemukan");
    }

    await FirebaseAuthDatasource().updatePhotoBase64(
      uid: _user!.uid,
      base64: base64,
    );

    // 🔥 WAJIB: reload user biar homepage ikut berubah
    await loadUser(_user!.uid);

  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

// ================= UPDATE PROFILE =================
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

    await FirebaseAuthDatasource().updateUserProfile(
      uid: _user!.uid,
      name: name,
      phone: phone,
    );

    // 🔥 JANGAN sentuh photoPath lagi!
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


  // ================= LOAD USER DARI FIRESTORE =================
   Future<void> loadUser(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      _user = UserModel.fromMap(doc.data()!);
      notifyListeners();
    }
  }
}
