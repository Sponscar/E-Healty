import 'package:flutter/material.dart';
import '../../core/utils/network_helper.dart';
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

   // khusus untuk testing
  AktivitasSehatProvider.forTest({
    required CreateAktivitas create,
    required GetAktivitas get,
    required UpdateAktivitas update,
    required DeleteAktivitas delete,
  }) {
    _create = create;
    _get = get;
    _update = update;
    _delete = delete;
  }

  List<AktivitasModel> list = [];
  bool loading = false;
  String? errorMessage;

  String _uid(BuildContext c) =>
      c.read<AuthProvider>().user!.uid;

  Future<void> load(BuildContext c) async {
    try {
      loading = true;
      errorMessage = null;
      notifyListeners();

      list = await _get(_uid(c));

    } catch (e) {
      errorMessage = NetworkHelper.getErrorMessage(e);
      debugPrint(e.toString());
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> add({
    required BuildContext context,
    required String judul,
    required String deskripsi,
    String? imageBase64,
  }) async {

    // Validasi input
    if (judul.trim().isEmpty) {
      throw ArgumentError('Judul tidak boleh kosong');
    }
    if (deskripsi.trim().isEmpty) {
      throw ArgumentError('Deskripsi tidak boleh kosong');
    }

    // Cek koneksi internet
    final hasInternet = await NetworkHelper.hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    }

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
    // Validasi input
    if (m.judul.trim().isEmpty) {
      throw ArgumentError('Judul tidak boleh kosong');
    }
    if (m.deskripsi.trim().isEmpty) {
      throw ArgumentError('Deskripsi tidak boleh kosong');
    }

    try {
      loading = true;
      errorMessage = null;
      notifyListeners();

      await _update(m);
      await load(c);

    } catch (e) {
      errorMessage = NetworkHelper.getErrorMessage(e);
      debugPrint(e.toString());
      rethrow; // Re-throw agar UI bisa handle
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> remove(
    BuildContext c,
    String id,
  ) async {
    // Cek koneksi internet
    final hasInternet = await NetworkHelper.hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    }

    await _delete(_uid(c), id);
    await load(c);
  }
}
