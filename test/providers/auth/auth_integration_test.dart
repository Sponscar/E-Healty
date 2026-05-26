import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:e_healty/domain/entities/user.dart';
import 'package:e_healty/presentation/providers/auth_provider.dart';
import './mocks.mocks.dart';

void main() {
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockLogoutUseCase mockLogout;
  late MockUpdatePhotoUseCase mockUpdatePhoto;
  late MockFirebaseAuthDatasource mockDatasource;
  late MockUserEntity mockUser;
  late AuthProvider provider;

  MockUserEntity buildUser({
    String uid = 'uid-123',
    String name = 'Panji',
    String email = 'panji@email.com',
    String phone = '08123456789',
  }) {
    final u = MockUserEntity();
    when(u.uid).thenReturn(uid);
    when(u.name).thenReturn(name);
    when(u.email).thenReturn(email);
    when(u.phoneNumber).thenReturn(phone);
    when(u.role).thenReturn('user');
    when(u.photoBase64).thenReturn(null);
    when(u.copyWith(
      name: anyNamed('name'),
      phoneNumber: anyNamed('phoneNumber'),
      photoBase64: anyNamed('photoBase64'),
      photoPath: anyNamed('photoPath'),
    )).thenReturn(u);
    return u;
  }

  setUp(() {
    mockLogin       = MockLoginUseCase();
    mockRegister    = MockRegisterUseCase();
    mockLogout      = MockLogoutUseCase();
    mockUpdatePhoto = MockUpdatePhotoUseCase();
    mockDatasource  = MockFirebaseAuthDatasource();
    mockUser        = buildUser();

    provider = AuthProvider.forTest(
      login: mockLogin,
      register: mockRegister,
      logout: mockLogout,
      updatePhoto: mockUpdatePhoto,
      datasource: mockDatasource,
      loadUserFn: (uid) async => mockUser,
    );
  });

  // ════════════════════════════════════════════════════════
  // TC-01: Login → User tersedia di provider
  // LoginUseCase → loadUserFn → AuthProvider
  // ════════════════════════════════════════════════════════
  group('TC-01: Integrasi Login', () {

    // IT-01: happy path — login berhasil, user terisi
    test('IT-01: login() berhasil mengisi user dan membersihkan error',
        () async {
      when(mockLogin('panji@email.com', 'pass123'))
          .thenAnswer((_) async => mockUser);

      await provider.login('panji@email.com', 'pass123');

      // Verifikasi alur: LoginUseCase → loadUserFn → user terisi
      expect(provider.user, isNotNull);
      expect(provider.user!.uid, 'uid-123');
      expect(provider.user!.name, 'Panji');
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, false);
    });

    // IT-02: error path — login gagal, errorMessage terisi
    test('IT-02: login() gagal mengisi errorMessage tanpa crash', () async {
      when(mockLogin(any, any)).thenThrow(Exception('Kredensial salah'));

      await provider.login('salah@email.com', 'wrongpass');

      // Verifikasi alur: LoginUseCase throw → catch → errorMessage
      expect(provider.user, isNull);
      expect(provider.errorMessage, equals("Email atau password salah"));
      expect(provider.isLoading, false);
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-02: Login → ClearError → State bersih
  // LoginUseCase → AuthProvider → clearError()
  // ════════════════════════════════════════════════════════
  group('TC-02: Integrasi Login lalu ClearError', () {

    // IT-03: error muncul lalu dibersihkan
    test('IT-03: errorMessage bisa dibersihkan setelah login gagal', () async {
      when(mockLogin(any, any)).thenThrow(Exception('Error'));
      await provider.login('x@x.com', 'x');
      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      // Verifikasi alur: error → clearError() → null
      expect(provider.errorMessage, isNull);
    });

    // IT-04: multiple scenario — login gagal, clear, login berhasil
    test('IT-04: setelah clearError() login berhasil berjalan normal',
        () async {
      // Login gagal dulu
      when(mockLogin(any, any)).thenThrow(Exception('Error'));
      await provider.login('x@x.com', 'x');
      provider.clearError();

      // Login berhasil setelahnya
      when(mockLogin('panji@email.com', 'pass123'))
          .thenAnswer((_) async => mockUser);
      await provider.login('panji@email.com', 'pass123');

      expect(provider.user, isNotNull);
      expect(provider.errorMessage, isNull);
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-03: Register → User tersedia di provider
  // RegisterUseCase → AuthProvider
  // ════════════════════════════════════════════════════════
  group('TC-03: Integrasi Register', () {

    // IT-05: happy path — register berhasil, user terisi
    test('IT-05: register() berhasil mengisi user', () async {
      when(mockRegister('baru@email.com', 'pass123', 'Budi', '08999'))
          .thenAnswer((_) async => mockUser);

      await provider.register('baru@email.com', 'pass123', 'Budi', '08999');

      expect(provider.user, isNotNull);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    // IT-06: error path — register gagal, errorMessage terisi
    test('IT-06: register() gagal mengisi errorMessage', () async {
      when(mockRegister(any, any, any, any))
          .thenThrow(Exception('Email sudah digunakan'));

      await provider.register('ada@email.com', 'pass', 'nama', '08123');

      expect(provider.user, isNull);
      expect(provider.errorMessage, contains("Email sudah digunakan"));
      expect(provider.isLoading, false);
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-04: Login → Logout → State bersih
  // LoginUseCase → LogoutUseCase → AuthProvider
  // ════════════════════════════════════════════════════════
  group('TC-04: Integrasi Login lalu Logout', () {

    // IT-07: happy path — login lalu logout, user null
    test('IT-07: user null setelah login lalu logout()', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('panji@email.com', 'pass123');
      expect(provider.user, isNotNull);

      when(mockLogout()).thenAnswer((_) async {});
      await provider.logout();

      // Verifikasi alur: login → user terisi → logout → user null
      expect(provider.user, isNull);
      expect(provider.isLoading, false);
    });

    // IT-08: multiple scenario — logout lalu login lagi
    test('IT-08: bisa login kembali setelah logout()', () async {
      // Login pertama
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('panji@email.com', 'pass123');

      // Logout
      when(mockLogout()).thenAnswer((_) async {});
      await provider.logout();
      expect(provider.user, isNull);

      // Login kedua
      await provider.login('panji@email.com', 'pass123');
      expect(provider.user, isNotNull);
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-05: Login → UpdatePhotoBase64 → User terupdate
  // LoginUseCase → FirebaseAuthDatasource → loadUserFn
  // ════════════════════════════════════════════════════════
  group('TC-05: Integrasi Login lalu UpdatePhoto', () {

    // IT-09: happy path — update foto berhasil
    test('IT-09: updatePhotoBase64() berhasil setelah login', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('panji@email.com', 'pass123');

      when(mockDatasource.updatePhotoBase64(
        uid: anyNamed('uid'),
        base64: anyNamed('base64'),
      )).thenAnswer((_) async {});

      await provider.updatePhotoBase64('base64encoded');

      // Verifikasi alur: user ada → update foto → reload user
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      verify(mockDatasource.updatePhotoBase64(
        uid: 'uid-123',
        base64: 'base64encoded',
      )).called(1);
    });

    // IT-10: error path — update foto gagal karena user null
    test('IT-10: updatePhotoBase64() gagal jika belum login', () async {
      // Tidak login dulu — user null
      await provider.updatePhotoBase64('base64encoded');

      // Verifikasi alur: user null → throw → errorMessage terisi
      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, false);
      verifyNever(mockDatasource.updatePhotoBase64(
        uid: anyNamed('uid'),
        base64: anyNamed('base64'),
      ));
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-06: Login → UpdateProfile → User terupdate
  // LoginUseCase → FirebaseAuthDatasource → copyWith
  // ════════════════════════════════════════════════════════
  group('TC-06: Integrasi Login lalu UpdateProfile', () {

    // IT-11: happy path — update profile berhasil
    test('IT-11: updateProfile() berhasil memperbarui data user', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('panji@email.com', 'pass123');

      when(mockDatasource.updateUserProfile(
        uid: anyNamed('uid'),
        name: anyNamed('name'),
        phone: anyNamed('phone'),
      )).thenAnswer((_) async {});

      await provider.updateProfile(name: 'Panji Update', phone: '08999');

      // Verifikasi alur: user ada → updateUserProfile → copyWith
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      verify(mockDatasource.updateUserProfile(
        uid: 'uid-123',
        name: 'Panji Update',
        phone: '08999',
      )).called(1);
    });

    // IT-12: error path — update profile gagal karena user null
    test('IT-12: updateProfile() gagal jika belum login', () async {
      await provider.updateProfile(name: 'Panji', phone: '08123');

      // Verifikasi alur: user null → throw → errorMessage terisi
      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, false);
      verifyNever(mockDatasource.updateUserProfile(
        uid: anyNamed('uid'),
        name: anyNamed('name'),
        phone: anyNamed('phone'),
      ));
    });

    // IT-13: multiple scenario — update profile 2x berturut-turut
    test('IT-13: updateProfile() bisa dipanggil 2x berturut-turut', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('panji@email.com', 'pass123');

      when(mockDatasource.updateUserProfile(
        uid: anyNamed('uid'),
        name: anyNamed('name'),
        phone: anyNamed('phone'),
      )).thenAnswer((_) async {});

      await provider.updateProfile(name: 'Nama 1', phone: '08111');
      await provider.updateProfile(name: 'Nama 2', phone: '08222');

      // Verifikasi dipanggil 2x
      verify(mockDatasource.updateUserProfile(
        uid: anyNamed('uid'),
        name: anyNamed('name'),
        phone: anyNamed('phone'),
      )).called(2);
      expect(provider.isLoading, false);
    });
  });

  // ════════════════════════════════════════════════════════
  // TC-07: Login → LoadUser → Home Page
  // LoginUseCase → loadUserFn → AuthProvider (Home)
  // ════════════════════════════════════════════════════════
  group('TC-07: Integrasi Login lalu LoadUser (Home)', () {

    // IT-14: happy path — login lalu loadUser berhasil
    test('IT-14: loadUser() berhasil memuat ulang data user saat masuk Home',
        () async {
      // Login dulu
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('panji@email.com', 'pass123');
      expect(provider.user, isNotNull);

      // Simulasi loadUser saat HomePage.initState
      await provider.loadUser('uid-123');

      // Verifikasi alur: login → user terisi → loadUser → user tetap terisi
      expect(provider.user, isNotNull);
      expect(provider.user!.uid, 'uid-123');
      expect(provider.user!.name, 'Panji');
    });

    // IT-15: edge case — loadUser dengan uid yang tidak ditemukan
    test('IT-15: loadUser() tidak menimpa user jika data tidak ditemukan',
        () async {
      final providerNullLoad = AuthProvider.forTest(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        updatePhoto: mockUpdatePhoto,
        datasource: mockDatasource,
        loadUserFn: (uid) async => null, // simulasi user tidak ditemukan
      );

      // Login berhasil (user terisi dari login)
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await providerNullLoad.login('panji@email.com', 'pass123');

      // loadUser gagal menemukan data di Firestore
      await providerNullLoad.loadUser('uid-999');

      // Verifikasi: user dari login masih ada, tidak ditimpa null
      // Karena login() juga memanggil _loadUserFn yang return null,
      // maka user tetap dari _login result
      expect(providerNullLoad.user, isNotNull);
    });

    // IT-16: multiple scenario — loadUser dipanggil berulang
    test('IT-16: loadUser() bisa dipanggil berulang tanpa error', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('panji@email.com', 'pass123');

      // Panggil loadUser 3 kali (simulasi navigasi bolak-balik ke Home)
      await provider.loadUser('uid-123');
      await provider.loadUser('uid-123');
      await provider.loadUser('uid-123');

      expect(provider.user, isNotNull);
      expect(provider.isLoading, false);
    });
  });
}