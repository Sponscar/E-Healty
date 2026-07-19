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

  // ════════════════════════════════════════════════════════
  // TC-01: Load Tips — GetTipsKesehatan → TipsKesehatanProvider
  // ════════════════════════════════════════════════════════
  group('TC-01: Integrasi Load Tips Kesehatan', () {

    // IT-01: fungsi berhasil — data tersedia
    test('IT-01: loadTips() berhasil mengambil semua data dari repository',
        () async {
      final data = [
        dummyTips(id: '1', title: 'Minum Air'),
        dummyTips(id: '2', title: 'Tidur Cukup'),
        dummyTips(id: '3', title: 'Olahraga Rutin'),
      ];

      // Pre-condition: repository mengembalikan 3 data
      when(mockGetAll()).thenAnswer((_) async => data);

      await provider.loadTips();

      // Expected result: list terisi 3 data, loading selesai
      expect(provider.list.length, 3);
      expect(provider.list.first.title, 'Minum Air');
      expect(provider.list.last.title, 'Olahraga Rutin');
      expect(provider.loading, false);
    });

    // IT-02: fungsi gagal — repository error
    test('IT-02: loadTips() tetap aman saat repository throw exception',
        () async {
      // Pre-condition: repository error (misal Firestore offline)
      when(mockGetAll()).thenThrow(Exception('Koneksi gagal'));

      await provider.loadTips();

      // Expected result: list kosong, loading tetap false (tidak crash)
      expect(provider.list, isEmpty);
      expect(provider.loading, false);
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-02: Load Tips lalu Ambil Detail
  // GetTipsKesehatan → GetTipsKesehatanDetail → Provider
  // ════════════════════════════════════════════════════════
  group('TC-02: Integrasi Load lalu Detail Tips Kesehatan', () {

    // IT-03: fungsi berhasil — load lalu ambil detail salah satu
    test('IT-03: loadTips() lalu detail() mengembalikan data yang konsisten',
        () async {
      final data = [
        dummyTips(id: 'tips-A', title: 'Makan Sehat', author: 'dr. Gizi'),
        dummyTips(id: 'tips-B', title: 'Jalan Kaki', author: 'dr. Sport'),
      ];
      final detailData = dummyTips(
        id: 'tips-A',
        title: 'Makan Sehat',
        content: 'Konsumsi sayur dan buah setiap hari',
        author: 'dr. Gizi',
      );

      // Pre-condition: load berhasil, detail tersedia
      when(mockGetAll()).thenAnswer((_) async => data);
      when(mockGetDetail('tips-A')).thenAnswer((_) async => detailData);

      await provider.loadTips();
      final result = await provider.detail('tips-A');

      // Expected result: data list dan detail konsisten
      expect(provider.list.length, 2);
      expect(result.id, 'tips-A');
      expect(result.title, provider.list.first.title); // konsisten
      expect(result.author, 'dr. Gizi');
    });

    // IT-04: multiple data — detail hanya mengambil yang ditarget
    test('IT-04: detail() hanya mengambil data dengan id yang diminta',
        () async {
      final detailB = dummyTips(
        id: 'tips-B',
        title: 'Jalan Kaki',
        content: 'Jalan kaki 30 menit sehari',
        author: 'dr. Sport',
      );

      when(mockGetDetail('tips-B')).thenAnswer((_) async => detailB);

      final result = await provider.detail('tips-B');

      // Expected result: hanya data tips-B yang dikembalikan
      expect(result.id, 'tips-B');
      expect(result.title, 'Jalan Kaki');
      verify(mockGetDetail('tips-B')).called(1);
      verifyNever(mockGetDetail('tips-A')); // tips-A tidak dipanggil
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-03: Detail Tips — GetTipsKesehatanDetail → Provider
  // ════════════════════════════════════════════════════════
  group('TC-03: Integrasi Detail Tips Kesehatan', () {

    // IT-05: fungsi berhasil — detail ditemukan
    test('IT-05: detail() mengembalikan entity lengkap berdasarkan id',
        () async {
      final tips = dummyTips(
        id: 'tips-99',
        title: 'Meditasi',
        content: 'Meditasi 10 menit setiap pagi',
        author: 'dr. Mental',
      );

      // Pre-condition: id ditemukan di repository
      when(mockGetDetail('tips-99')).thenAnswer((_) async => tips);

      final result = await provider.detail('tips-99');

      // Expected result: semua field sesuai
      expect(result.id, 'tips-99');
      expect(result.title, 'Meditasi');
      expect(result.content, 'Meditasi 10 menit setiap pagi');
      expect(result.author, 'dr. Mental');
    });

    // IT-06: fungsi gagal — id tidak ditemukan
    test('IT-06: detail() meneruskan exception jika id tidak ada di repository',
        () async {
      // Pre-condition: id tidak ditemukan
      when(mockGetDetail('id-tidak-ada'))
          .thenThrow(Exception('Data tidak ditemukan'));

      // Expected result: exception diteruskan ke caller
      expect(
        () => provider.detail('id-tidak-ada'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-04: Reload Tips — Load ulang setelah pertama
  // ════════════════════════════════════════════════════════
  group('TC-04: Integrasi Reload Tips Kesehatan', () {

    // IT-07: reload — data terbaru menggantikan data lama
    test('IT-07: loadTips() kedua menggantikan list dari loadTips() pertama',
        () async {
      final dataAwal = [
        dummyTips(id: '1', title: 'Tips Lama'),
      ];
      final dataBaru = [
        dummyTips(id: '1', title: 'Tips Lama'),
        dummyTips(id: '2', title: 'Tips Baru'),
        dummyTips(id: '3', title: 'Tips Terbaru'),
      ];

      // Load pertama
      when(mockGetAll()).thenAnswer((_) async => dataAwal);
      await provider.loadTips();
      expect(provider.list.length, 1);

      // Load kedua (data bertambah)
      when(mockGetAll()).thenAnswer((_) async => dataBaru);
      await provider.loadTips();

      // Expected result: list diperbarui dengan data terbaru
      expect(provider.list.length, 3);
      expect(provider.list.last.title, 'Tips Terbaru');
    });

    // IT-08: multiple user scenario — setiap panggil loadTips reset loading
    test('IT-08: loadTips() selalu mereset loading ke false setelah selesai',
        () async {
      when(mockGetAll()).thenAnswer((_) async => [
        dummyTips(id: '1', title: 'Tips A'),
      ]);

      // Panggil 2 kali simulasi multi request
      await provider.loadTips();
      expect(provider.loading, false);

      await provider.loadTips();
      expect(provider.loading, false);

      // Verifikasi _getAll dipanggil 2 kali
      verify(mockGetAll()).called(2);
    });
  });
}