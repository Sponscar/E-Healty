import '../../domain/entities/tips_kesehatan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TipsKesehatanModel extends TipsKesehatanEntity {
  TipsKesehatanModel({
    required super.id,
    required super.title,
    required super.content,
    required super.imageUrl,
    required super.createdAt,
    required super.author,
  });

  factory TipsKesehatanModel.fromMap(String id, Map<String, dynamic> map) {
    return TipsKesehatanModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      author: map['author'] ?? '',
    );
  }
}
