import '../../entities/tips_kesehatan.dart';
import '../../../data/repositories/tips_kesehatan_repository.dart';

class GetTipsKesehatan {
  final TipsKesehatanRepository repository;

  GetTipsKesehatan(this.repository);

  Future<List<TipsKesehatanEntity>> call() {
    return repository.getAll();
  }
}
