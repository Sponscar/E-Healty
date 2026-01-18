import '../../../data/models/aktivitas_model.dart';
import '../../../data/repositories/aktivitas_repository.dart';

class GetAktivitas {
  final AktivitasRepository repo;
  GetAktivitas(this.repo);

  Future<List<AktivitasModel>> call(String uid) =>
      repo.getByUid(uid);
}
