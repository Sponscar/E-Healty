import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:e_healty/data/models/aktivitas_model.dart';
import 'package:e_healty/presentation/providers/aktivitas_sehat_provider.dart';
import 'package:e_healty/presentation/providers/auth_provider.dart';
import 'package:e_healty/core/utils/network_helper.dart';
import './mocks.mocks.dart';

// ─── Helper: buat BuildContext palsu dengan Provider ───
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
  late AktivitasSehatProvider provider; // ← deklarasi di luar setUp

  setUp(() {
    mockGet = MockGetAktivitas();
    mockCreate = MockCreateAktivitas();
    mockUpdate = MockUpdateAktivitas();
    mockDelete = MockDeleteAktivitas();
    mockAuth = MockAuthProvider();
    mockUserEntity = MockUserEntity();

    // ✅ forTest — tidak menyentuh Firebase sama sekali
    provider = AktivitasSehatProvider.forTest(
      create: mockCreate,
      get: mockGet,
      update: mockUpdate,
      delete: mockDelete,
    );

    when(mockAuth.user).thenReturn(mockUserEntity);
    when(mockUserEntity.uid).thenReturn('user-123');

    // Skip cek internet saat testing
    NetworkHelper.skipNetworkCheck = true;
  });

  tearDown(() {
    NetworkHelper.skipNetworkCheck = false;
  });

  // ════════════════════════════════════════════
  // GROUP: load()
  // ════════════════════════════════════════════
  group('load()', () {
    testWidgets('loading menjadi true lalu false saat load()', (tester) async {
      final aktivitasList = [
        AktivitasModel(
          id: '1',
          uid: 'user-123',
          judul: 'Lari',
          deskripsi: 'Lari pagi',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockGet('user-123')).thenAnswer((_) async => aktivitasList);

      final loadingStates = <bool>[];
      provider.addListener(() => loadingStates.add(provider.loading));

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => provider.load(ctx),
                child: const Text('Load'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Load'));
      await tester.pumpAndSettle();

      // White box: urutan state internal harus [true, false]
      expect(loadingStates, equals([true, false]));
      expect(provider.list, equals(aktivitasList));
    });

    testWidgets('list terisi data dari _get setelah load()', (tester) async {
      final data = [
        AktivitasModel(
          id: 'a1',
          uid: 'user-123',
          judul: 'Yoga',
          deskripsi: 'Yoga sore',
          createdAt: DateTime.now(),
        ),
        AktivitasModel(
          id: 'a2',
          uid: 'user-123',
          judul: 'Renang',
          deskripsi: 'Renang pagi',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockGet('user-123')).thenAnswer((_) async => data);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => provider.load(ctx),
                child: const Text('Load'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Load'));
      await tester.pumpAndSettle();

      expect(provider.list.length, 2);
      expect(provider.list.first.judul, 'Yoga');
    });
  });

  // ════════════════════════════════════════════
  // GROUP: add()
  // ════════════════════════════════════════════
  group('add()', () {
    testWidgets('add() membuat model dengan uid dan judul yang benar', (
      tester,
    ) async {
      AktivitasModel? capturedModel;

      when(mockCreate(any)).thenAnswer((inv) async {
        capturedModel = inv.positionalArguments[0] as AktivitasModel;
      });
      when(mockGet('user-123')).thenAnswer((_) async => []);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => provider.add(
                  context: ctx,
                  judul: 'Jogging',
                  deskripsi: 'Jogging 30 menit',
                ),
                child: const Text('Add'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // White box: verifikasi isi model yang dibuat oleh add()
      expect(capturedModel, isNotNull);
      expect(capturedModel!.uid, 'user-123'); // dari _uid()
      expect(capturedModel!.judul, 'Jogging');
      expect(capturedModel!.id, isNotEmpty); // UUID dibuat
    });

    testWidgets('add() memanggil _create lalu _get', (tester) async {
      when(mockCreate(any)).thenAnswer((_) async {});
      when(mockGet('user-123')).thenAnswer((_) async => []);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => provider.add(
                  context: ctx,
                  judul: 'Sit Up',
                  deskripsi: '50 kali',
                ),
                child: const Text('Add'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // White box: verifikasi urutan pemanggilan internal
      verify(mockCreate(any)).called(1);
      verify(mockGet('user-123')).called(1);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: add() — MODIFIKASI (validasi input)
  // ════════════════════════════════════════════
  group('add() validasi input [MODIFIKASI]', () {
    // Test case 1 — invalid input: judul kosong
    testWidgets('add() throw error jika judul kosong', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () async {
                  try {
                    await provider.add(
                      context: ctx,
                      judul: '', // ← invalid: kosong
                      deskripsi: 'Deskripsi valid',
                    );
                  } catch (_) {}
                },
                child: const Text('Add'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // _create tidak boleh dipanggil jika validasi gagal
      verifyNever(mockCreate(any));
    });

    // Test case 2 — invalid input: deskripsi kosong
    testWidgets('add() throw error jika deskripsi kosong', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () async {
                  try {
                    await provider.add(
                      context: ctx,
                      judul: 'Judul valid',
                      deskripsi: '', // ← invalid: kosong
                    );
                  } catch (_) {}
                },
                child: const Text('Add'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // _create tidak boleh dipanggil jika validasi gagal
      verifyNever(mockCreate(any));
    });

    // Test case 3 — boundary: judul hanya spasi
    testWidgets('add() throw error jika judul hanya spasi', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () async {
                  try {
                    await provider.add(
                      context: ctx,
                      judul: '   ', // ← boundary: trim → kosong
                      deskripsi: 'Deskripsi valid',
                    );
                  } catch (_) {}
                },
                child: const Text('Add'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      verifyNever(mockCreate(any));
    });
  });

  // ════════════════════════════════════════════
  // GROUP: edit()
  // ════════════════════════════════════════════
  group('edit()', () {
    testWidgets('edit() memanggil _update dengan model yang benar', (
      tester,
    ) async {
      final model = AktivitasModel(
        id: 'xyz',
        uid: 'user-123',
        judul: 'Push Up Edit',
        deskripsi: 'Edit deskripsi',
        createdAt: DateTime.now(),
      );

      when(mockUpdate(any)).thenAnswer((_) async {});
      when(mockGet('user-123')).thenAnswer((_) async => [model]);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => provider.edit(ctx, model),
                child: const Text('Edit'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      verify(mockUpdate(model)).called(1);
      verify(mockGet('user-123')).called(1);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: remove()
  // ════════════════════════════════════════════
  group('remove()', () {
    testWidgets('remove() memanggil _delete dengan uid dan id yang benar', (
      tester,
    ) async {
      when(mockDelete('user-123', 'id-hapus')).thenAnswer((_) async {});
      when(mockGet('user-123')).thenAnswer((_) async => []);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => provider.remove(ctx, 'id-hapus'),
                child: const Text('Remove'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // White box: verifikasi argumen yang dikirim ke _delete
      verify(mockDelete('user-123', 'id-hapus')).called(1);
    });

    testWidgets('remove() memperbarui list menjadi kosong setelah hapus', (
      tester,
    ) async {
      when(mockDelete(any, any)).thenAnswer((_) async {});
      when(mockGet('user-123')).thenAnswer((_) async => []);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => provider.remove(ctx, 'id-hapus'),
                child: const Text('Remove'),
              );
            },
          ),
          authProvider: mockAuth,
        ),
      );

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(provider.list, isEmpty);
    });
  });
}
