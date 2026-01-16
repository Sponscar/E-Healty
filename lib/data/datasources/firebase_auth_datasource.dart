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

  Future logout() async {
    await _auth.signOut();
  }
}
