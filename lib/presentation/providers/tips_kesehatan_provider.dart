import 'package:flutter/material.dart';

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

  List<TipsKesehatanEntity> _list = [];
  bool _loading = false;

  List<TipsKesehatanEntity> get list => _list;
  bool get loading => _loading;

  Future<void> loadTips() async {
    try {
      _loading = true;
      notifyListeners();

      _list = await _getAll();

    } catch (e) {
      debugPrint(e.toString());
    }

    _loading = false;
    notifyListeners();
  }

  Future<TipsKesehatanEntity> detail(String id) {
    return _getDetail(id);
  }
}
