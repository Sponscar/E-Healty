import '../datasources/firestore_service_datasource.dart';
import '../models/aktivitas_model.dart';

class AktivitasRepository {
  final FirestoreServiceDatasource ds;

  AktivitasRepository(this.ds);

  Future<void> create(AktivitasModel m) => ds.create(m);

  Future<List<AktivitasModel>> getByUid(String uid) =>
      ds.getByUid(uid);

  Future<void> update(AktivitasModel m) => ds.update(m);

  Future<void> delete(String uid, String id) =>
      ds.delete(uid, id);
}
