class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String? photoPath;
  final String? photoBase64;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.photoPath,
    this.photoBase64,
  });

  // helper copyWith (biar gampang update sebagian data)
  UserEntity copyWith({
    String? name,
    String? phoneNumber,
    String? photoPath,
    String? photoBase64,
  }) {
    return UserEntity(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      photoPath: photoPath ?? this.photoPath,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }
}
