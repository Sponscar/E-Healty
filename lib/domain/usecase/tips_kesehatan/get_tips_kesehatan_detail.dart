import '../../entities/tips_kesehatan.dart';
import '../../../data/repositories/tips_kesehatan_repository.dart';

class GetTipsKesehatanDetail {
  final TipsKesehatanRepository repository;

  GetTipsKesehatanDetail(this.repository);

  Future<TipsKesehatanEntity> call(String id) {
    return repository.getDetail(id);
  }
}
