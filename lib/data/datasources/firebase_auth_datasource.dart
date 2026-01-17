import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatPhone(String phone) {
    if (phone.startsWith("08")) {
      return "+62${phone.substring(1)}";
    }
    return phone;
  }
  
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    // 1️⃣ BUAT AKUN AUTH
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = result.user!.uid;

    final user = UserModel(
      uid: uid,
      email: email,
      name: name,
      phoneNumber: formatPhone(phoneNumber),
      role: 'user',
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .set(user.toMap());

    return user;
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'name': name,
        'phoneNumber': phone,
      });
    } catch (e) {
      throw Exception("Gagal update profile: $e");
    }
  }


  Future<UserModel> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection('users')
        .doc(result.user!.uid)
        .get();

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updatePhotoBase64({
    required String uid,
    required String base64,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      "photoBase64": base64,
    });
  }


  Future<void> updatePhotoPath(String uid, String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final base64Image = base64Encode(bytes);

      await _firestore.collection('users').doc(uid).update({
        "photoBase64": base64Image,
      });

    } catch (e) {
      throw Exception("Gagal simpan foto: $e");
    }
  }

  Future logout() async {
    await _auth.signOut();
  }
}
