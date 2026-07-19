# LAPORAN HASIL PENGUJIAN PERANGKAT LUNAK
## Sistem Aplikasi Kesehatan (E-Healty)

&nbsp;

| | |
|---|---|
| **Nama Pengembang** | Panji Riski Krisna R S, Naila Nur Hidayah |
| **Tanggal Uji** | Rabu, 20 Mei 2026 |
| **Versi Sistem** | 1.0.0 |
| **Environment Unit and Integration Testing** | Flutter 3.9.2 \| Dart \| flutter_test \| Mockito \| Windows 11 |
| **Penguji 1** | Panji Riski Krisna R S |
| **NIM 1** | 3012310050 |
| **Penguji 2** | Naila Nur Hidayah |
| **NIM 2** | 3012310029 |
| **Penguji 3** | Karina Cahyasari |
| **NIM 3** | 3012310012 |

---

## 1. RINGKASAN EKSEKUTIF

Pengujian perangkat lunak dilakukan terhadap aplikasi E-Healty yang dikembangkan menggunakan framework Flutter dan bahasa pemrograman Dart. Proses pengujian mencakup dua level utama, yaitu Unit Testing dan Integration Testing. Pengujian dilakukan untuk memastikan bahwa seluruh fungsi utama sistem berjalan sesuai dengan spesifikasi kebutuhan serta mampu menangani kondisi normal, error handling, dan boundary value dengan baik.

Berdasarkan hasil pengujian yang telah dilakukan, dari total 72 test case yang terdiri dari 40 Unit Test dan 32 Integration Test, ditemukan **2 kegagalan** pada modul **Auth (Register)** dengan tingkat keberhasilan mencapai **97.2%**. Kedua kegagalan tersebut disebabkan oleh bug pada error handling fungsi `register()` di `AuthProvider`, dimana pesan error tidak disimpan ke `_errorMessage` saat proses registrasi gagal (misalnya email sudah terdaftar), sehingga pengguna tidak mendapatkan feedback yang sesuai.

| Level Pengujian | Total Test Case | Passed | Failed |
|---|---|---|---|
| Unit Testing | 40 | 39 | 1 |
| Integration Testing | 32 | 31 | 1 |
| **TOTAL** | **72** | **70** | **2 (2.8%)** |

---

## 2. HASIL UNIT TESTING

### 2.1 Rekap Test Suite

| Test Suite (Kelas) | Skenario Utama | Jumlah TC | Passed | Status |
|---|---|---|---|---|
| **Penguji 1** | | | | |
| Panji Riski K R S | Login() | 4 | 4 | PASS |
| Panji Riski K R S | clearError() | 1 | 1 | PASS |
| Panji Riski K R S | Register() | 3 | 2 | **FAIL** |
| Panji Riski K R S | Logout() | 2 | 2 | PASS |
| Panji Riski K R S | updatePhotoBase64() | 3 | 3 | PASS |
| Panji Riski K R S | updateProfil() | 3 | 3 | PASS |
| Panji Riski K R S | loadUser() | 3 | 3 | PASS |
| **Subtotal Penguji 1** | | **19** | **18** | **FAIL** |
| **Penguji 2** | | | | |
| Naila Nur Hidayah | Load() | 2 | 2 | PASS |
| Naila Nur Hidayah | Add() | 2 | 2 | PASS |
| Naila Nur Hidayah | Add() validasi input | 3 | 3 | PASS |
| Naila Nur Hidayah | Edit() | 1 | 1 | PASS |
| Naila Nur Hidayah | Remove() | 2 | 2 | PASS |
| **Subtotal Penguji 2** | | **10** | **10** | **PASS** |
| **Penguji 3** | | | | |
| Gizha Nasywa I P | loadTips() | 5 | 5 | PASS |
| Gizha Nasywa I P | Detail() | 3 | 3 | PASS |
| Gizha Nasywa I P | reloadTips() | 3 | 3 | PASS |
| **Subtotal Penguji 3** | | **11** | **11** | **PASS** |
| **Total Unit Test** | | **40** | **39** | **FAIL** |

### 2.2 Detail Temuan

Ditemukan **1 kegagalan** dalam unit testing pada modul Auth bagian Register. Berikut catatan dari proses pengujian:

**1. Nama Penguji 1: Panji Riski K R S**
- Proses login berhasil memvalidasi autentikasi pengguna dengan benar, termasuk penanganan kondisi login gagal dan pengelolaan errorMessage.
- Fungsi register mampu menambahkan data pengguna baru, **namun ditemukan kegagalan pada penanganan error saat registrasi gagal**. Ketika email sudah terdaftar, sistem tidak menyimpan pesan error ke `_errorMessage` sehingga pengguna tidak mendapat feedback yang seharusnya.
- Fungsi logout berhasil menghapus data sesi pengguna tanpa menyebabkan error pada state aplikasi.
- Fitur updatePhotoBase64() dan updateProfile() berhasil memperbarui data profil pengguna serta menjaga konsistensi state setelah proses update.
- Fungsi loadUser() mampu memuat ulang data pengguna dengan benar serta tetap aman ketika data pengguna tidak ditemukan.
- Seluruh proses perubahan state seperti isLoading, errorMessage, dan notifyListeners() berjalan sesuai ekspektasi, **kecuali pada fungsi register() dimana errorMessage tidak terisi saat terjadi exception**.

> [!CAUTION]
> **Unit Test FAIL — Register() errorMessage terisi jika register throw exception**
> ```
> Expected: contains 'Email sudah digunakan'
>   Actual: <null>
>    Which: is not a string, map or iterable
> ```
> **Lokasi Bug**: `lib/presentation/providers/auth_provider.dart` line 108-110
> **Penyebab**: Catch block pada fungsi `register()` tidak menyimpan error ke `_errorMessage`, sehingga saat register gagal (misal email duplikat), user tidak mendapat informasi penyebab kegagalan.

**2. Nama Penguji 2: Naila Nur Hidayah**
- Fungsi load() berhasil mengambil dan menampilkan data aktivitas sehat dari repository.
- Fungsi add() berhasil menambahkan data aktivitas baru serta memperbarui list data secara otomatis.
- Validasi input pada fitur penambahan aktivitas berhasil mencegah input kosong maupun input yang hanya berisi spasi.
- Fungsi edit() mampu memperbarui data aktivitas yang dipilih tanpa memengaruhi data lainnya.
- Fungsi remove() berhasil menghapus data aktivitas dan memperbarui state list setelah proses penghapusan.
- Seluruh operasi CRUD berjalan stabil tanpa ditemukan inkonsistensi data.

**3. Nama Penguji 3: Gizha Nasywa I P**
- Fungsi loadTips() berhasil mengambil seluruh data tips kesehatan dari repository dengan baik.
- Sistem tetap stabil ketika repository menghasilkan exception atau data kosong.
- Fungsi detail() berhasil mengambil detail data berdasarkan id yang diminta secara akurat.
- Proses reloadTips() berhasil memperbarui isi list data sesuai data terbaru dari repository.
- State loading selalu kembali ke kondisi normal (false) setelah proses selesai, termasuk ketika terjadi error.
- Seluruh pengujian menunjukkan bahwa modul tips kesehatan memiliki mekanisme error handling yang baik dan stabil.

---

## 3. HASIL INTEGRATION TESTING

### 3.1 Rekap Test Suite Integrasi

| Test Suite | Skenario Utama | Jumlah TC | Status |
|---|---|---|---|
| **Penguji 1** | | | |
| Panji Riski K R S | TC-01: Integrasi Login | 2 | PASS |
| Panji Riski K R S | TC-02: Integrasi Login lalu ClearError | 2 | PASS |
| Panji Riski K R S | TC-03: Integrasi Register | 2 | **FAIL** |
| Panji Riski K R S | TC-04: Integrasi Login lalu Logout | 2 | PASS |
| Panji Riski K R S | TC-05: Integrasi Login lalu UpdatePhoto | 2 | PASS |
| Panji Riski K R S | TC-06: Integrasi Login lalu UpdateProfile | 3 | PASS |
| Panji Riski K R S | TC-07: Integrasi Login lalu LoadUser | 3 | PASS |
| **Subtotal Penguji 1** | | **16** | **FAIL** |
| **Penguji 2** | | | |
| Naila Nur Hidayah | TC-01: Integrasi Load Aktivitas | 2 | PASS |
| Naila Nur Hidayah | TC-02: Integrasi Add Aktivitas | 2 | PASS |
| Naila Nur Hidayah | TC-03: Integrasi Edit Aktivitas | 2 | PASS |
| Naila Nur Hidayah | TC-04: Integrasi Remove Aktivitas | 2 | PASS |
| **Subtotal Penguji 2** | | **8** | **PASS** |
| **Penguji 3** | | | |
| Gizha Nasywa I P | TC-01: Integrasi Load Tips | 2 | PASS |
| Gizha Nasywa I P | TC-02: Integrasi Load lalu Detail | 2 | PASS |
| Gizha Nasywa I P | TC-03: Integrasi Detail Tips | 2 | PASS |
| Gizha Nasywa I P | TC-04: Integrasi Reload Tips | 2 | PASS |
| **Subtotal Penguji 3** | | **8** | **PASS** |
| **Total Integration Test** | | **32** | **FAIL** |

> [!CAUTION]
> **Integration Test FAIL — TC-03: Integrasi Register → IT-06: register() gagal mengisi errorMessage**
> ```
> Expected: contains 'Email sudah digunakan'
>   Actual: <null>
>    Which: is not a string, map or iterable
> ```
> **Penyebab**: Bug yang sama dengan unit test — catch block pada fungsi `register()` di `auth_provider.dart` tidak menyimpan error ke `_errorMessage`. Saat integrasi antara `RegisterUseCase` dan `AuthProvider`, error dari usecase (email sudah terdaftar) tidak diteruskan ke state provider sehingga UI tidak dapat menampilkan pesan error kepada pengguna.

### 3.2 Verifikasi Konsistensi Data

Pengujian konsistensi data dilakukan untuk memastikan bahwa perubahan state pada aplikasi tetap sinkron dan sesuai dengan kondisi sebenarnya setelah proses operasi dijalankan.

**Verifikasi: AuthProvider**
- Setelah proses login berhasil, data user selalu terisi dengan benar dan errorMessage kembali menjadi null.
- Setelah logout dilakukan, state pengguna berhasil dikosongkan tanpa menyisakan data sesi sebelumnya.
- Proses loadUser() tidak menimpa data pengguna apabila data baru tidak ditemukan.
- Pemanggilan fungsi updateProfile() dan updatePhotoBase64() secara berulang tetap menjaga konsistensi state aplikasi.
- **Ditemukan inkonsistensi pada fungsi register()**: saat registrasi gagal, `errorMessage` tetap bernilai `null` padahal seharusnya berisi pesan error. Hal ini menyebabkan UI tidak sinkron dengan kondisi error yang sebenarnya terjadi.

**Verifikasi: AktivitasSehatProvider**
- Setelah proses add(), data aktivitas baru langsung muncul pada list hasil load().
- Setelah proses edit(), perubahan data hanya terjadi pada item yang dipilih tanpa memengaruhi item lainnya.
- Setelah proses remove(), data berhasil dihapus dan list otomatis diperbarui sesuai kondisi terbaru repository.
- Pengujian validasi berhasil memastikan data invalid tidak tersimpan ke dalam sistem.

**Verifikasi: TipsKesehatanProvider**
- Data hasil detail() selalu konsisten dengan data yang telah dimuat melalui loadTips().
- Proses reloadTips() berhasil menggantikan data lama dengan data terbaru dari repository.
- Kondisi repository kosong maupun exception tidak menyebabkan crash ataupun inkonsistensi state aplikasi.
- State loading selalu kembali ke nilai false setelah proses selesai dijalankan.

---

## 4. ANALISIS KUALITAS

### 4.1 Distribusi Jenis Test Case

| Jenis Test Case | Unit Testing | Integration Testing | Persentase |
|---|---|---|---|
| Happy Path (valid input) | 26 | 21 | 65.3% |
| Error Handling (invalid input / exception) | 10 | 7 | 23.6% |
| Boundary Value (batas nilai / edge case) | 4 | 4 | 11.1% |
| **Total** | **40** | **32** | **100%** |

### 4.2 Waktu Eksekusi

Seluruh 72 test case berhasil dieksekusi dalam waktu sekitar 1 detik. Tidak ditemukan pengujian yang mengindikasikan adanya performance issue maupun penurunan performa sistem selama proses testing berlangsung.

Rata-rata waktu eksekusi per test case berada pada kisaran < 15 ms, sehingga masih jauh di bawah threshold performa yang ditetapkan, yaitu 100 ms per test case. Hasil ini menunjukkan bahwa proses autentikasi, pengelolaan aktivitas sehat, serta pengambilan data tips kesehatan dapat berjalan dengan cepat dan stabil pada environment pengujian yang digunakan.

### 4.3 Analisis Bug yang Ditemukan

| Atribut | Detail |
|---|---|
| **Bug ID** | BUG-001 |
| **Modul** | Auth → Register |
| **Severity** | **High** |
| **Lokasi** | `lib/presentation/providers/auth_provider.dart` line 108-110 |
| **Test yang Fail** | Unit Test: `register() errorMessage terisi jika register throw exception` |
| | Integration Test: `TC-03 IT-06: register() gagal mengisi errorMessage` |
| **Deskripsi** | Catch block pada fungsi `register()` tidak menyimpan exception ke `_errorMessage`. Saat register gagal (misal email sudah terdaftar), `_errorMessage` tetap `null` sehingga UI tidak menampilkan feedback error kepada pengguna. |

**Code yang bermasalah:**
```dart
} catch (e) {
  // Bug: error tidak disimpan ke _errorMessage
  _user = null;
}
```

**Perbaikan yang direkomendasikan:**
```dart
} catch (e) {
  _errorMessage = e.toString().replaceAll("Exception:", "");
}
```

### 4.4 Rekomendasi

1. **Memperbaiki bug pada fungsi register()** di `auth_provider.dart` agar pesan error tersimpan ke `_errorMessage` dan pengguna mendapat feedback yang sesuai saat registrasi gagal.
2. Menambahkan pengujian UI Testing / Widget Testing untuk memastikan tampilan antarmuka berjalan sesuai perilaku yang diharapkan pengguna.
3. Menambahkan pengujian concurrent access atau simulasi akses bersamaan untuk menguji kestabilan aplikasi ketika digunakan oleh banyak pengguna secara simultan.
4. Mengimplementasikan code coverage report menggunakan tools seperti `flutter test --coverage` guna mengukur tingkat cakupan pengujian secara kuantitatif.
5. Menambahkan pengujian terhadap kondisi jaringan tidak stabil atau kegagalan koneksi database/API untuk meningkatkan robustness aplikasi.
6. Menambahkan pengujian performa sederhana, seperti pengukuran waktu loading data dan respon aplikasi pada proses CRUD maupun autentikasi.
7. Memperluas skenario boundary value dan negative testing untuk memastikan aplikasi tetap stabil pada kondisi input ekstrem atau tidak valid.

---

## 5. KESIMPULAN

Pengujian perangkat lunak aplikasi E-Healty telah berhasil dilaksanakan menggunakan metode Unit Testing dan Integration Testing. Berdasarkan hasil pengujian yang dilakukan, dari total 72 test case yang dijalankan, **70 test case berhasil (PASS)** dan **2 test case gagal (FAIL)** dengan tingkat keberhasilan sebesar **97.2%**.

Kedua kegagalan terjadi pada modul **Auth** bagian **Register**, disebabkan oleh bug pada error handling fungsi `register()` di `AuthProvider`. Bug ini menyebabkan pesan error tidak tersimpan ke state `_errorMessage` saat proses registrasi gagal (misalnya email sudah terdaftar), sehingga pengguna tidak mendapatkan feedback yang seharusnya ditampilkan pada halaman Register.

Selain bug tersebut, seluruh fitur utama lainnya termasuk Login, Logout, Update Profile, Update Photo, Load User, serta modul Aktivitas Sehat dan Tips Kesehatan berjalan sesuai dengan spesifikasi kebutuhan. Mekanisme validasi, pengelolaan state, integrasi antar modul, serta penanganan error pada modul-modul tersebut telah berjalan dengan baik dan stabil.

Dengan hasil tersebut, aplikasi E-Healty **memerlukan perbaikan pada fungsi register()** sebelum dilanjutkan ke tahap pengujian berikutnya maupun tahap implementasi sistem. Setelah bug diperbaiki dan seluruh test case lolos, aplikasi dinyatakan layak untuk dilanjutkan sesuai rencana pengembangan perangkat lunak yang telah ditetapkan.

&nbsp;

| | |
|---|---|
| Mengetahui, | Dibuat oleh, |
| Dosen Pengampu | Mahasiswa |
| | |
| (\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_) | (\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_) |
