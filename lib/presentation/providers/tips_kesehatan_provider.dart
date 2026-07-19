import 'package:flutter/material.dart';

import '../../core/utils/network_helper.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/repositories/tips_kesehatan_repository.dart';
import '../../domain/entities/tips_kesehatan.dart';
import '../../domain/usecase/tips_kesehatan/get_tips_kesehatan.dart';
import '../../domain/usecase/tips_kesehatan/get_tips_kesehatan_detail.dart';

class TipsKesehatanProvider extends ChangeNotifier {

  late final GetTipsKesehatan _getAll;
  late final GetTipsKesehatanDetail _getDetail;

  TipsKesehatanProvider() {
    final repo = TipsKesehatanRepository(FirestoreDatasource());
    _getAll = GetTipsKesehatan(repo);
    _getDetail = GetTipsKesehatanDetail(repo);
  }

   // ← TAMBAHKAN INI — khusus testing
  TipsKesehatanProvider.forTest({
    required GetTipsKesehatan getAll,
    required GetTipsKesehatanDetail getDetail,
  }) {
    _getAll = getAll;
    _getDetail = getDetail;
  }

  List<TipsKesehatanEntity> _list = [];
  bool _loading = false;
  String? _errorMessage;

  List<TipsKesehatanEntity> get list => _list;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTips() async {
    try {
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      // Cek koneksi internet
      final hasInternet = await NetworkHelper.hasInternetConnection();
      if (!hasInternet) {
        _errorMessage = "Tidak ada koneksi internet. Periksa koneksi Anda.";
        _loading = false;
        notifyListeners();
        return;
      }

      _list = await _getAll();

    } catch (e) {
      _errorMessage = NetworkHelper.getErrorMessage(e);
      debugPrint(e.toString());
    }

    _loading = false;
    notifyListeners();
  }

  Future<TipsKesehatanEntity> detail(String id) async {
    // Cek koneksi internet
    final hasInternet = await NetworkHelper.hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    }
    return _getDetail(id);
  }
}
