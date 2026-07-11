import 'package:mockito/annotations.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/create_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/get_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/update_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/delete_aktivitas.dart';
import 'package:e_healty/presentation/providers/auth_provider.dart' as app_auth;
import 'package:e_healty/domain/entities/user.dart';

// ← Tambahkan 2 import ini
import 'package:e_healty/domain/usecase/tips_kesehatan/get_tips_kesehatan.dart';
import 'package:e_healty/domain/usecase/tips_kesehatan/get_tips_kesehatan_detail.dart';

@GenerateMocks([
  CreateAktivitas,
  GetAktivitas,
  UpdateAktivitas,
  DeleteAktivitas,
  app_auth.AuthProvider,
  UserEntity,
  // ← Tambahkan 2 ini
  GetTipsKesehatan,
  GetTipsKesehatanDetail,
])
void main() {}
