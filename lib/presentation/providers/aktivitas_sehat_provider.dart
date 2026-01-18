import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/datasources/firestore_service_datasource.dart';
import '../../data/models/aktivitas_model.dart';
import '../../data/repositories/aktivitas_repository.dart';
import '../../domain/usecase/aktivitas_sehat/create_aktivitas.dart';
import '../../domain/usecase/aktivitas_sehat/get_aktivitas.dart';
import '../../domain/usecase/aktivitas_sehat/update_aktivitas.dart';
import '../../domain/usecase/aktivitas_sehat/delete_aktivitas.dart';
import 'auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AktivitasSehatProvider extends ChangeNotifier {
  late final CreateAktivitas _create;
  late final GetAktivitas _get;
  late final UpdateAktivitas _update;
  late final DeleteAktivitas _delete;

  AktivitasSehatProvider() {
    final repo =
        AktivitasRepository(FirestoreServiceDatasource());

    _create = CreateAktivitas(repo);
    _get = GetAktivitas(repo);
    _update = UpdateAktivitas(repo);
    _delete = DeleteAktivitas(repo);
  }

  List<AktivitasModel> list = [];
  bool loading = false;

  String _uid(BuildContext c) =>
      c.read<AuthProvider>().user!.uid;

  Future<void> load(BuildContext c) async {
    loading = true;
    notifyListeners();

    list = await _get(_uid(c));

    loading = false;
    notifyListeners();
  }

  Future<void> add({
    required BuildContext context,
    required String judul,
    required String deskripsi,
    String? imageBase64,
  }) async {
    final model = AktivitasModel(
      id: const Uuid().v4(),
      uid: _uid(context),
      judul: judul,
      deskripsi: deskripsi,
      imageBase64: imageBase64,
      createdAt: DateTime.now(),
    );

    await _create(model);
    await load(context);
  }

  Future<void> edit(
    BuildContext c,
    AktivitasModel m,
  ) async {
    await _update(m);
    await load(c);
  }

  Future<void> remove(
    BuildContext c,
    String id,
  ) async {
    await _delete(_uid(c), id);
    await load(c);
  }
}
