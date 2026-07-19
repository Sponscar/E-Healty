import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:e_healty/domain/entities/tips_kesehatan.dart';
import 'package:e_healty/presentation/providers/tips_kesehatan_provider.dart';
import 'package:e_healty/core/utils/network_helper.dart';
import './mocks.mocks.dart';

void main() {
  late MockGetTipsKesehatan mockGetAll;
  late MockGetTipsKesehatanDetail mockGetDetail;
  late TipsKesehatanProvider provider;

  // Helper buat dummy entity
  TipsKesehatanEntity dummyTips({
    String id = 'tips-1',
    String title = 'Minum Air',
    String content = 'Minum 8 gelas sehari',
    String imageUrl = 'https://example.com/img.jpg',
    String author = 'dr. Sehat',
  }) {
    return TipsKesehatanEntity(
      id: id,
      title: title,
      content: content,
      imageUrl: imageUrl,
      createdAt: DateTime(2024, 1, 1),
      author: author,
    );
  }

  setUp(() {
    mockGetAll    = MockGetTipsKesehatan();
    mockGetDetail = MockGetTipsKesehatanDetail();

    provider = TipsKesehatanProvider.forTest(
      getAll: mockGetAll,
      getDetail: mockGetDetail,
    );

    // Skip cek internet saat testing
    NetworkHelper.skipNetworkCheck = true;
  });

  tearDown(() {
    NetworkHelper.skipNetworkCheck = false;
  });

  // ════════════════════════════════════════════
  // GROUP: loadTips()
  // ════════════════════════════════════════════
  group('loadTips()', () {

    // Path 1 — happy path: urutan loading state
    test('loading menjadi true lalu false setelah loadTips()', () async {
      final data = [
        dummyTips(id: '1', title: 'Minum Air'),
        dummyTips(id: '2', title: 'Tidur Cukup'),
      ];

      when(mockGetAll()).thenAnswer((_) async => data);

      final loadingStates = <bool>[];
      provider.addListener(() => loadingStates.add(provider.loading));

      await provider.loadTips();

      // White box: urutan state internal harus [true, false]
      expect(loadingStates, equals([true, false]));
    });

    // Path 2 — happy path: list terisi dengan benar
    test('list terisi data dari _getAll setelah loadTips()', () async {
      final data = [
        dummyTips(id: '1', title: 'Minum Air'),
        dummyTips(id: '2', title: 'Tidur Cukup'),
      ];

      when(mockGetAll()).thenAnswer((_) async => data);

      await provider.loadTips();

      expect(provider.list.length, 2);
      expect(provider.list.first.title, 'Minum Air');
      expect(provider.list.first.author, 'dr. Sehat');
      expect(provider.loading, false);
    });

    // Path 3 — error path: exception ditangkap oleh try-catch
    test('list tetap kosong jika _getAll throw exception', () async {
      when(mockGetAll()).thenThrow(Exception('Firestore error'));

      await provider.loadTips();

      // White box: list tidak berubah karena error ditangkap di catch
      expect(provider.list, isEmpty);
    });

    // Path 4 — error path: loading tetap false meski exception
    test('loading kembali false meski _getAll throw exception', () async {
      when(mockGetAll()).thenThrow(Exception('Firestore error'));

      final loadingStates = <bool>[];
      provider.addListener(() => loadingStates.add(provider.loading));

      await provider.loadTips();

      // White box: _loading = false ada di luar try-catch, selalu dieksekusi
      expect(loadingStates, equals([true, false]));
      expect(provider.loading, false);
    });

    // Path 5 — boundary: repository mengembalikan list kosong
    test('list kosong jika repository tidak memiliki data', () async {
      when(mockGetAll()).thenAnswer((_) async => []);

      await provider.loadTips();

      expect(provider.list, isEmpty);
      expect(provider.loading, false);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: detail()
  // ════════════════════════════════════════════
  group('detail()', () {

    // Path 1 — happy path: mengembalikan entity yang benar
    test('detail() mengembalikan entity berdasarkan id', () async {
      final tips = dummyTips(
        id: 'tips-99',
        title: 'Olahraga Rutin',
        content: 'Olahraga minimal 30 menit sehari',
        author: 'dr. Fitnes',
      );

      when(mockGetDetail('tips-99')).thenAnswer((_) async => tips);

      final result = await provider.detail('tips-99');

      expect(result.id, 'tips-99');
      expect(result.title, 'Olahraga Rutin');
      expect(result.content, 'Olahraga minimal 30 menit sehari');
      expect(result.author, 'dr. Fitnes');
    });

    // Path 2 — error path: exception diteruskan jika id tidak ditemukan
    test('detail() meneruskan exception jika id tidak ditemukan', () async {
      when(mockGetDetail('id-salah'))
          .thenThrow(Exception('Data tidak ditemukan'));

      expect(
        () => provider.detail('id-salah'),
        throwsA(isA<Exception>()),
      );
    });

    // Path 3 — verifikasi _getDetail dipanggil dengan id yang benar
    test('detail() meneruskan id yang benar ke _getDetail', () async {
      final tips = dummyTips(id: 'tips-55', title: 'Sarapan');

      when(mockGetDetail('tips-55')).thenAnswer((_) async => tips);

      await provider.detail('tips-55');

      // White box: verifikasi argumen yang dikirim ke usecase
      verify(mockGetDetail('tips-55')).called(1);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: reloadTips() — Test 15: Reload Tips
  // ════════════════════════════════════════════
  group('reloadTips()', () {

    // Path 1 — reload: data terbaru menggantikan data lama
    test('loadTips() kedua menggantikan list dari loadTips() pertama',
        () async {
      final dataAwal = [
        dummyTips(id: '1', title: 'Tips Lama'),
      ];
      final dataBaru = [
        dummyTips(id: '1', title: 'Tips Lama'),
        dummyTips(id: '2', title: 'Tips Baru'),
      ];

      // Load pertama
      when(mockGetAll()).thenAnswer((_) async => dataAwal);
      await provider.loadTips();
      expect(provider.list.length, 1);

      // Load kedua (data bertambah)
      when(mockGetAll()).thenAnswer((_) async => dataBaru);
      await provider.loadTips();

      // White box: _list di-replace seluruhnya oleh data baru
      expect(provider.list.length, 2);
      expect(provider.list.last.title, 'Tips Baru');
    });

    // Path 2 — reload: loading tetap false setelah multiple load
    test('loading selalu kembali false setelah setiap loadTips()', () async {
      when(mockGetAll()).thenAnswer((_) async => [
            dummyTips(id: '1', title: 'Tips A'),
          ]);

      await provider.loadTips();
      expect(provider.loading, false);

      await provider.loadTips();
      expect(provider.loading, false);

      // White box: setiap panggilan loadTips() selalu reset loading
      verify(mockGetAll()).called(2);
    });

    // Path 3 — reload: data kosong setelah sebelumnya ada data
    test('loadTips() bisa mengembalikan list kosong setelah sebelumnya terisi',
        () async {
      // Load pertama ada data
      when(mockGetAll()).thenAnswer((_) async => [
            dummyTips(id: '1', title: 'Tips Ada'),
          ]);
      await provider.loadTips();
      expect(provider.list.length, 1);

      // Load kedua kosong
      when(mockGetAll()).thenAnswer((_) async => []);
      await provider.loadTips();

      // White box: _list diganti seluruhnya, jadi sekarang kosong
      expect(provider.list, isEmpty);
    });
  });
}