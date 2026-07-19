import 'package:firebase_auth/firebase_auth.dart';

/// Utility class untuk menerjemahkan error Firebase ke Bahasa Indonesia
class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  /// Map Firebase Auth error ke pesan Bahasa Indonesia
  static String mapAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar. Silakan gunakan email lain.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'weak-password':
          return 'Password terlalu lemah. Minimal 6 karakter.';
        case 'user-not-found':
          return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
        case 'wrong-password':
          return 'Password salah. Silakan coba lagi.';
        case 'user-disabled':
          return 'Akun Anda telah dinonaktifkan. Hubungi admin.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
        case 'operation-not-allowed':
          return 'Operasi tidak diizinkan. Hubungi admin.';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet. Periksa koneksi Anda.';
        case 'invalid-credential':
          return 'Email atau password salah.';
        default:
          return 'Terjadi kesalahan: ${error.message ?? error.code}';
      }
    }

    // Cek network error dari pesan string
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('timeout') ||
        msg.contains('failed host lookup')) {
      return 'Tidak ada koneksi internet. Periksa koneksi Anda.';
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
