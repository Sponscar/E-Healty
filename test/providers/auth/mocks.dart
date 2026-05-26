import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:e_healty/domain/usecase/aktivitas_sehat/create_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/get_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/update_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/delete_aktivitas.dart';
import 'package:e_healty/presentation/providers/auth_provider.dart' as app_auth;
import 'package:e_healty/domain/entities/user.dart';
import 'package:e_healty/domain/usecase/tips_kesehatan/get_tips_kesehatan.dart';
import 'package:e_healty/domain/usecase/tips_kesehatan/get_tips_kesehatan_detail.dart';

// ← Tambahkan 5 import ini
import 'package:e_healty/domain/usecase/auth/login.dart';
import 'package:e_healty/domain/usecase/auth/register.dart';
import 'package:e_healty/domain/usecase/auth/logout.dart';
import 'package:e_healty/domain/usecase/auth/update_photo.dart';
import 'package:e_healty/data/datasources/firebase_auth_datasource.dart';

@GenerateMocks([
  CreateAktivitas,
  GetAktivitas,
  UpdateAktivitas,
  DeleteAktivitas,
  app_auth.AuthProvider,
  UserEntity,
  GetTipsKesehatan,
  GetTipsKesehatanDetail,
  // ← Tambahkan 5 ini
  LoginUseCase,
  RegisterUseCase,
  LogoutUseCase,
  UpdatePhotoUseCase,
  FirebaseAuthDatasource,
])
void main() {}