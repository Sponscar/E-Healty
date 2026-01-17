import '../../../data/repositories/auth_repository.dart';

class UpdatePhotoUseCase {
  final AuthRepository repository;

  UpdatePhotoUseCase(this.repository);

  Future<void> call(String uid, String path) {
    return repository.updatePhotoPath(uid, path);
  }
}
