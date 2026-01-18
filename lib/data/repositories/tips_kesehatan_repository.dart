import '../datasources/firestore_datasource.dart';
import '../../domain/entities/tips_kesehatan.dart';

class TipsKesehatanRepository {
  final FirestoreDatasource datasource;

  TipsKesehatanRepository(this.datasource);

  Future<List<TipsKesehatanEntity>> getAll() {
    return datasource.getTipsKesehatan();
  }

  Future<TipsKesehatanEntity> getDetail(String id) {
    return datasource.getTipsDetail(id);
  }
}
