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

  setUp(() {
    mockLogin       = MockLoginUseCase();
    mockRegister    = MockRegisterUseCase();
    mockLogout      = MockLogoutUseCase();
    mockUpdatePhoto = MockUpdatePhotoUseCase();
    mockDatasource  = MockFirebaseAuthDatasource();
    mockUser        = MockUserEntity();

    when(mockUser.uid).thenReturn('uid-123');
    when(mockUser.name).thenReturn('Panji');
    when(mockUser.photoBase64).thenReturn(null); // ← fix error
    when(mockUser.copyWith(
      name: anyNamed('name'),
      phoneNumber: anyNamed('phoneNumber'),
      photoBase64: anyNamed('photoBase64'),
      photoPath: anyNamed('photoPath'),
    )).thenReturn(mockUser);

    provider = AuthProvider.forTest(
      login: mockLogin,
      register: mockRegister,
      logout: mockLogout,
      updatePhoto: mockUpdatePhoto,
      datasource: mockDatasource,
      loadUserFn: (uid) async => mockUser,
    );
  });

  // ════════════════════════════════════════════
  // GROUP: login()
  // ════════════════════════════════════════════
  group('login()', () {

    test('isLoading menjadi true lalu false saat login()', () async {
      when(mockLogin('test@email.com', '123456'))
          .thenAnswer((_) async => mockUser);

      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoading));

      await provider.login('test@email.com', '123456');

      // White box: urutan isLoading harus [true, false]
      expect(states, equals([true, false]));
    });

    test('user terisi dan errorMessage null setelah login berhasil', () async {
      when(mockLogin('test@email.com', '123456'))
          .thenAnswer((_) async => mockUser);

      await provider.login('test@email.com', '123456');

      expect(provider.user, isNotNull);
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, false);
    });

    test('errorMessage terisi jika login throw exception', () async {
      when(mockLogin(any, any)).thenThrow(Exception('Kredensial salah'));

      await provider.login('salah@email.com', 'wrongpass');

      // White box: error ditangkap di catch, user tetap null
      expect(provider.errorMessage, equals("Email atau password salah"));
      expect(provider.user, isNull);
      expect(provider.isLoading, false);
    });

    test('isLoading kembali false meski login throw exception', () async {
      when(mockLogin(any, any)).thenThrow(Exception('Error'));

      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoading));

      await provider.login('x@x.com', 'x');

      // White box: finally selalu dieksekusi
      expect(states, equals([true, false]));
      expect(provider.isLoading, false);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: clearError()
  // ════════════════════════════════════════════
  group('clearError()', () {

    test('clearError() mengosongkan errorMessage', () async {
      when(mockLogin(any, any)).thenThrow(Exception('Error'));
      await provider.login('x@x.com', 'x');
      expect(provider.errorMessage, isNotNull);

      // White box: clearError langsung set null dan notifyListeners
      provider.clearError();

      expect(provider.errorMessage, isNull);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: register()
  // ════════════════════════════════════════════
  group('register()', () {

    test('user terisi setelah register berhasil', () async {
      when(mockRegister('new@email.com', 'pass123', 'Panji', '08123'))
          .thenAnswer((_) async => mockUser);

      await provider.register('new@email.com', 'pass123', 'Panji', '08123');

      expect(provider.user, isNotNull);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('errorMessage terisi jika register throw exception', () async {
      when(mockRegister(any, any, any, any))
          .thenThrow(Exception('Email sudah digunakan'));

      await provider.register('ada@email.com', 'pass', 'nama', '08123');

      // White box: Exception: dihapus dari pesan error
      expect(provider.errorMessage, contains("Email sudah digunakan"));
      expect(provider.user, isNull);
    });

    test('isLoading menjadi true lalu false saat register()', () async {
      when(mockRegister(any, any, any, any))
          .thenAnswer((_) async => mockUser);

      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoading));

      await provider.register('new@email.com', 'pass123', 'Panji', '08123');

      expect(states, equals([true, false]));
    });
  });

  // ════════════════════════════════════════════
  // GROUP: logout()
  // ════════════════════════════════════════════
  group('logout()', () {

    test('user menjadi null setelah logout()', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('test@email.com', '123456');
      expect(provider.user, isNotNull);

      when(mockLogout()).thenAnswer((_) async {});
      await provider.logout();

      // White box: _user di-set null lalu notifyListeners
      expect(provider.user, isNull);
    });

    test('_logout dipanggil saat logout()', () async {
      when(mockLogout()).thenAnswer((_) async {});
      await provider.logout();

      verify(mockLogout()).called(1);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: updatePhotoBase64()
  // ════════════════════════════════════════════
  group('updatePhotoBase64()', () {

    test('errorMessage terisi jika user null saat updatePhotoBase64()',
        () async {
      final providerNoUser = AuthProvider.forTest(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        updatePhoto: mockUpdatePhoto,
        datasource: mockDatasource,
        loadUserFn: (uid) async => null,
      );

      await providerNoUser.updatePhotoBase64('base64string');

      // White box: if (_user == null) throw Exception
      expect(providerNoUser.errorMessage, isNotNull);
      expect(providerNoUser.isLoading, false);
    });

    test('updatePhotoBase64() berhasil update foto dan reload user', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('test@email.com', '123456');

      when(mockDatasource.updatePhotoBase64(
        uid: anyNamed('uid'),
        base64: anyNamed('base64'),
      )).thenAnswer((_) async {});

      await provider.updatePhotoBase64('base64encoded');

      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      verify(mockDatasource.updatePhotoBase64(
        uid: 'uid-123',
        base64: 'base64encoded',
      )).called(1);
    });

    test('isLoading menjadi true lalu false saat updatePhotoBase64()',
        () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('test@email.com', '123456');

      when(mockDatasource.updatePhotoBase64(
        uid: anyNamed('uid'),
        base64: anyNamed('base64'),
      )).thenAnswer((_) async {});

      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoading));

      await provider.updatePhotoBase64('base64encoded');

      expect(states, contains(true));
      expect(provider.isLoading, false);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: updateProfile()
  // ════════════════════════════════════════════
  group('updateProfile()', () {

    test('errorMessage terisi jika user null saat updateProfile()', () async {
      final providerNoUser = AuthProvider.forTest(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        updatePhoto: mockUpdatePhoto,
        datasource: mockDatasource,
        loadUserFn: (uid) async => null,
      );

      await providerNoUser.updateProfile(name: 'Budi', phone: '08999');

      // White box: if (_user == null) throw Exception
      expect(providerNoUser.errorMessage, isNotNull);
      expect(providerNoUser.isLoading, false);
    });

    test('updateProfile() memperbarui data user dengan benar', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('test@email.com', '123456');

      when(mockDatasource.updateUserProfile(
        uid: anyNamed('uid'),
        name: anyNamed('name'),
        phone: anyNamed('phone'),
      )).thenAnswer((_) async {});

      await provider.updateProfile(name: 'Panji Baru', phone: '08999');

      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      verify(mockDatasource.updateUserProfile(
        uid: 'uid-123',
        name: 'Panji Baru',
        phone: '08999',
      )).called(1);
    });

    test('isLoading menjadi true lalu false saat updateProfile()', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => mockUser);
      await provider.login('test@email.com', '123456');

      when(mockDatasource.updateUserProfile(
        uid: anyNamed('uid'),
        name: anyNamed('name'),
        phone: anyNamed('phone'),
      )).thenAnswer((_) async {});

      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoading));

      await provider.updateProfile(name: 'Panji', phone: '08123');

      expect(states, contains(true));
      expect(provider.isLoading, false);
    });
  });

  // ════════════════════════════════════════════
  // GROUP: loadUser() — Test 4: Home / Beranda
  // ════════════════════════════════════════════
  group('loadUser()', () {

    test('loadUser() mengisi user jika loadUserFn mengembalikan data', () async {
      // White box: loadUser() → _loadUserFn → jika tidak null → _user = loaded
      await provider.loadUser('uid-123');

      expect(provider.user, isNotNull);
      expect(provider.user!.uid, 'uid-123');
    });

    test('loadUser() tidak mengubah user jika loadUserFn mengembalikan null',
        () async {
      final providerNoUser = AuthProvider.forTest(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        updatePhoto: mockUpdatePhoto,
        datasource: mockDatasource,
        loadUserFn: (uid) async => null,
      );

      await providerNoUser.loadUser('uid-999');

      // White box: if (loaded != null) tidak terpenuhi, _user tetap null
      expect(providerNoUser.user, isNull);
    });

    test('loadUser() memanggil notifyListeners jika data ditemukan', () async {
      final states = <bool>[];
      provider.addListener(() => states.add(provider.user != null));

      await provider.loadUser('uid-123');

      // White box: notifyListeners dipanggil setelah _user diisi
      expect(states, contains(true));
    });
  });
}