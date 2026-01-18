import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tips_kesehatan_model.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= GET ALL TIPS =================
  Future<List<TipsKesehatanModel>> getTipsKesehatan() async {
    try {
      final result = await _firestore
          .collection('tips_kesehatan')
          .orderBy('createdAt', descending: true)
          .get();

      return result.docs
          .map((e) => TipsKesehatanModel.fromMap(
                e.id,
                e.data(),
              ))
          .toList();

    } catch (e) {
      throw Exception("Gagal mengambil data tips: $e");
    }
  }

  // ================= GET DETAIL =================
  Future<TipsKesehatanModel> getTipsDetail(String id) async {
    try {
      final doc = await _firestore
          .collection('tips_kesehatan')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception("Tips tidak ditemukan");
      }

      return TipsKesehatanModel.fromMap(
        doc.id,
        doc.data()!,
      );

    } catch (e) {
      throw Exception("Gagal mengambil detail tips: $e");
    }
  }

  // ================= ADMIN: CREATE =================
  Future<void> createTips(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('tips_kesehatan').add({
        ...data,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Gagal menambah tips: $e");
    }
  }

  // ================= ADMIN: UPDATE =================
  Future<void> updateTips(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('tips_kesehatan')
          .doc(id)
          .update(data);
    } catch (e) {
      throw Exception("Gagal update tips: $e");
    }
  }

  // ================= ADMIN: DELETE =================
  Future<void> deleteTips(String id) async {
    try {
      await _firestore
          .collection('tips_kesehatan')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception("Gagal hapus tips: $e");
    }
  }
}