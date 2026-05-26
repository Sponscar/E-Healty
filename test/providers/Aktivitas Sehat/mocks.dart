import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:e_healty/domain/usecase/aktivitas_sehat/create_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/get_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/update_aktivitas.dart';
import 'package:e_healty/domain/usecase/aktivitas_sehat/delete_aktivitas.dart';
import 'package:e_healty/presentation/providers/auth_provider.dart' as app_auth;
import 'package:e_healty/domain/entities/user.dart'; // ← sesuaikan path-nya

@GenerateMocks([
  CreateAktivitas,
  GetAktivitas,
  UpdateAktivitas,
  DeleteAktivitas,
  app_auth.AuthProvider,
  UserEntity, 
])
void main() {}