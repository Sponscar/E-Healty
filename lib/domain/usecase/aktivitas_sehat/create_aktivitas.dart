import '../../../data/models/aktivitas_model.dart';
import '../../../data/repositories/aktivitas_repository.dart';

class CreateAktivitas {
  final AktivitasRepository repo;
  CreateAktivitas(this.repo);

  Future<void> call(AktivitasModel m) => repo.create(m);
}
