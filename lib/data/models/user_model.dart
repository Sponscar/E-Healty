import 'package:e_healty/domain/entities/user.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.role,
    super.photoPath,
    super.photoBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "role": role,
      "photoPath": photoPath,
      "photoBase64": photoBase64,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      role: map['role'],
      photoPath: map['photoPath'],
      photoBase64: map['photoBase64'],
    );
  }
}
