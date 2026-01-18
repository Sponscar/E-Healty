class AktivitasSehat {
  final String id;
  final String uid;
  final String judul;
  final String deskripsi;
  final String? imageBase64;
  final DateTime createdAt;

  AktivitasSehat({
    required this.id,
    required this.uid,
    required this.judul,
    required this.deskripsi,
    this.imageBase64,
    required this.createdAt,
  });

  AktivitasSehat copyWith({
    String? judul,
    String? deskripsi,
    String? imageBase64,
  }) {
    return AktivitasSehat(
      id: id,
      uid: uid,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      imageBase64: imageBase64 ?? this.imageBase64,
      createdAt: createdAt,
    );
  }
}
