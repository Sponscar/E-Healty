import 'package:e_healty/data/models/aktivitas_model.dart';
import 'package:e_healty/data/repositories/aktivitas_repository.dart';

class UpdateAktivitas {
  final AktivitasRepository repo;
  UpdateAktivitas(this.repo);

  Future<void> call(AktivitasModel m) =>
      repo.update(m);
}
