import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'package:e_healty/data/models/aktivitas_model.dart';
import 'package:e_healty/presentation/providers/aktivitas_sehat_provider.dart';
import 'package:e_healty/presentation/providers/auth_provider.dart';
import './mocks.mocks.dart';

// ─── Helper ───
Widget buildTestApp({
  required Widget child,
  required AuthProvider authProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  late MockGetAktivitas mockGet;
  late MockCreateAktivitas mockCreate;
  late MockUpdateAktivitas mockUpdate;
  late MockDeleteAktivitas mockDelete;
  late MockAuthProvider mockAuth;
  late MockUserEntity mockUserEntity;
  late AktivitasSehatProvider provider;

  setUp(() {
    mockGet        = MockGetAktivitas();
    mockCreate     = MockCreateAktivitas();
    mockUpdate     = MockUpdateAktivitas();
    mockDelete     = MockDeleteAktivitas();
    mockAuth       = MockAuthProvider();
    mockUserEntity = MockUserEntity();

    provider = AktivitasSehatProvider.forTest(
      create: mockCreate,
      get: mockGet,
      update: mockUpdate,
      delete: mockDelete,
    );

    when(mockAuth.user).thenReturn(mockUserEntity);
    when(mockUserEntity.uid).thenReturn('user-123');
  });

  // ════════════════════════════════════════════════════════
  // TC-01: Load aktivitas berhasil
  // AuthProvider → GetAktivitas → AktivitasSehatProvider
  // ════════════════════════════════════════════════════════
  group('TC-01: Integrasi Load Aktivitas', () {

    // IT-01: fungsi berhasil — data tersedia
    testWidgets('IT-01: load() berhasil mengambil data dari repository',
        (tester) async {
      final data = [
        AktivitasModel(
          id: '1', uid: 'user-123',
          judul: 'Lari Pagi', deskripsi: 'Lari 30 menit',
          createdAt: DateTime.now(),
        ),
        AktivitasModel(
          id: '2', uid: 'user-123',
          judul: 'Yoga', deskripsi: 'Yoga sore',
          createdAt: DateTime.now(),
        ),
      ];

      // Pre-condition: repository mengembalikan 2 data
      when(mockGet('user-123')).thenAnswer((_) async => data);

      await tester.pumpWidget(buildTestApp(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => provider.load(ctx),
            child: const Text('Load'),
          );
        }),
        authProvider: mockAuth,
      ));

      await tester.tap(find.text('Load'));
      await tester.pumpAndSettle();

      // Expected result: list terisi 2 data, loading selesai
      expect(provider.list.length, 2);
      expect(provider.loading, false);
      expect(provider.list.first.judul, 'Lari Pagi');
    });

    // IT-02: fungsi gagal — repository kosong
    testWidgets('IT-02: load() mengembalikan list kosong jika tidak ada data',
        (tester) async {
      // Pre-condition: repository kosong
      when(mockGet('user-123')).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestApp(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => provider.load(ctx),
            child: const Text('Load'),
          );
        }),
        authProvider: mockAuth,
      ));

      await tester.tap(find.text('Load'));
      await tester.pumpAndSettle();

      // Expected result: list kosong, loading tetap selesai
      expect(provider.list, isEmpty);
      expect(provider.loading, false);
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-02: Add aktivitas lalu muncul di list
  // AuthProvider → CreateAktivitas → GetAktivitas
  // ════════════════════════════════════════════════════════
  group('TC-02: Integrasi Add Aktivitas', () {

    // IT-03: fungsi berhasil — data muncul setelah add
    testWidgets('IT-03: add() menyimpan data lalu list diperbarui',
        (tester) async {
      final newItem = AktivitasModel(
        id: 'new-1', uid: 'user-123',
        judul: 'Push Up', deskripsi: '50 kali',
        createdAt: DateTime.now(),
      );

      // Pre-condition: create berhasil, get mengembalikan item baru
      when(mockCreate(any)).thenAnswer((_) async {});
      when(mockGet('user-123')).thenAnswer((_) async => [newItem]);

      await tester.pumpWidget(buildTestApp(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => provider.add(
              context: ctx,
              judul: 'Push Up',
              deskripsi: '50 kali',
            ),
            child: const Text('Add'),
          );
        }),
        authProvider: mockAuth,
      ));

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expected result: list berisi 1 data baru
      expect(provider.list.length, 1);
      expect(provider.list.first.judul, 'Push Up');
      verify(mockCreate(any)).called(1);
    });

    // IT-04: fungsi gagal — validasi input kosong
    testWidgets('IT-04: add() gagal jika judul kosong, list tidak berubah',
        (tester) async {
      // Pre-condition: list awal kosong
      when(mockGet('user-123')).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestApp(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () async {
              try {
                await provider.add(
                  context: ctx,
                  judul: '',         // invalid input
                  deskripsi: 'Deskripsi',
                );
              } catch (_) {}
            },
            child: const Text('Add'),
          );
        }),
        authProvider: mockAuth,
      ));

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expected result: _create tidak dipanggil, list tetap kosong
      verifyNever(mockCreate(any));
      expect(provider.list, isEmpty);
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-03: Edit aktivitas lalu data terupdate di list
  // AuthProvider → UpdateAktivitas → GetAktivitas
  // ════════════════════════════════════════════════════════
  group('TC-03: Integrasi Edit Aktivitas', () {

    // IT-05: fungsi berhasil — data terupdate
    testWidgets('IT-05: edit() memperbarui data lalu list di-refresh',
        (tester) async {
      final updatedModel = AktivitasModel(
        id: 'edit-1', uid: 'user-123',
        judul: 'Jogging Edit', deskripsi: 'Jogging 1 jam',
        createdAt: DateTime.now(),
      );

      // Pre-condition: update berhasil, get mengembalikan data terbaru
      when(mockUpdate(any)).thenAnswer((_) async {});
      when(mockGet('user-123')).thenAnswer((_) async => [updatedModel]);

      await tester.pumpWidget(buildTestApp(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => provider.edit(ctx, updatedModel),
            child: const Text('Edit'),
          );
        }),
        authProvider: mockAuth,
      ));

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Expected result: list berisi data yang sudah diupdate
      expect(provider.list.first.judul, 'Jogging Edit');
      expect(provider.list.first.deskripsi, 'Jogging 1 jam');
      verify(mockUpdate(updatedModel)).called(1);
    });

    // IT-06: multiple data — edit salah satu, yang lain tidak berubah
    testWidgets('IT-06: edit() hanya mengubah data yang ditarget',
        (tester) async {
      final model1 = AktivitasModel(
        id: '1', uid: 'user-123',
        judul: 'Lari', deskripsi: 'Lari pagi',
        createdAt: DateTime.now(),
      );
      final model2edited = AktivitasModel(
        id: '2', uid: 'user-123',
        judul: 'Renang Edit', deskripsi: 'Renang 1 jam',
        createdAt: DateTime.now(),
      );

      when(mockUpdate(any)).thenAnswer((_) async {});
      // Setelah edit, get mengembalikan model1 utuh + model2 yang sudah diedit
      when(mockGet('user-123'))
          .thenAnswer((_) async => [model1, model2edited]);

      await tester.pumpWidget(buildTestApp(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => provider.edit(ctx, model2edited),
            child: const Text('Edit'),
          );
        }),
        authProvider: mockAuth,
      ));

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Expected result: list 2 item, item pertama tidak berubah
      expect(provider.list.length, 2);
      expect(provider.list[0].judul, 'Lari');         // tidak berubah
      expect(provider.list[1].judul, 'Renang Edit');  // sudah diedit
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-04: Remove aktivitas lalu hilang dari list
  // AuthProvider → DeleteAktivitas → GetAktivitas
  // ════════════════════════════════════════════════════════
  group('TC-04: Integrasi Remove Aktivitas', () {

    // IT-07: fungsi berhasil — data terhapus dari list
    testWidgets('IT-07: remove() menghapus data lalu list diperbarui',
        (tester) async {
      // Pre-condition: setelah hapus, repository kosong
      when(mockDelete('user-123', 'hapus-1')).thenAnswer((_) async {});
      when(mockGet('user-123')).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestApp(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => provider.remove(ctx, 'hapus-1'),
            child: const Text('Remove'),
          );
        }),
        authProvider: mockAuth,
      ));

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Expected result: list kosong setelah hapus
      expect(provider.list, isEmpty);
      verify(mockDelete('user-123', 'hapus-1')).called(1);
    });

    // IT-08: multiple data — hapus satu, yang lain tetap ada
    testWidgets('IT-08: remove() hanya menghapus data yang ditarget',
        (tester) async {
      final sisaModel = AktivitasModel(
        id: 'sisa-1', uid: 'user-123',
        judul: 'Yoga', deskripsi: 'Yoga pagi',
        createdAt: DateTime.now(),
      );

      // Pre-condition: setelah hapus id 'hapus-1', masih ada 'sisa-1'
      when(mockDelete('user-123', 'hapus-1')).thenAnswer((_) async {});
      when(mockGet('user-123')).thenAnswer((_) async => [sisaModel]);

      await tester.pumpWidget(buildTestApp(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => provider.remove(ctx, 'hapus-1'),
            child: const Text('Remove'),
          );
        }),
        authProvider: mockAuth,
      ));

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Expected result: masih ada 1 data yang tidak dihapus
      expect(provider.list.length, 1);
      expect(provider.list.first.judul, 'Yoga');
    });
  });
}