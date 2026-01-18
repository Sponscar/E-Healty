import 'package:e_healty/data/repositories/aktivitas_repository.dart';

class DeleteAktivitas {
  final AktivitasRepository repo;
  DeleteAktivitas(this.repo);

  Future<void> call(String uid, String id) =>
      repo.delete(uid, id);
}
