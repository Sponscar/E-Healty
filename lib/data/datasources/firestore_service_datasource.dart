import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aktivitas_model.dart';

class FirestoreServiceDatasource {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _ref =>
      _db.collection('users');

  CollectionReference aktivitasRef(String uid) =>
      _ref.doc(uid).collection('aktivitas_sehat');

  Future<void> create(AktivitasModel model) async {
    final data = model.toMap();

    // 🔥 Biar aman dari null aneh
    data.removeWhere((key, value) => value == null);

    await aktivitasRef(model.uid)
        .doc(model.id)
        .set(data);
  }

  Future<List<AktivitasModel>> getByUid(String uid) async {
    final snap = await aktivitasRef(uid)
        .orderBy("createdAt", descending: true)
        .get();

    return snap.docs
        .map((e) => AktivitasModel.fromMap(
            e.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> update(AktivitasModel model) async {
    await aktivitasRef(model.uid)
        .doc(model.id)
        .update(model.toMap());
  }

  Future<void> delete(String uid, String id) async {
    await aktivitasRef(uid).doc(id).delete();
  }
}
