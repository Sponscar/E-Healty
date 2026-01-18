import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/aktivitas_sehat.dart';

class AktivitasModel extends AktivitasSehat {
  AktivitasModel({
    required super.id,
    required super.uid,
    required super.judul,
    required super.deskripsi,
    super.imageBase64,
    required super.createdAt,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "uid": uid,
        "judul": judul,
        "deskripsi": deskripsi,
        "imageBase64": imageBase64,
        "createdAt": createdAt,
      };

  factory AktivitasModel.fromMap(Map<String, dynamic> map) {
    return AktivitasModel(
      id: map['id'],
      uid: map['uid'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      imageBase64: map['imageBase64'],

      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
    );
  }
}
