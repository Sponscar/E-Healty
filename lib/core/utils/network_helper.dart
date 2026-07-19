import 'dart:io';

class NetworkHelper {

  /// Flag untuk testing — skip cek internet saat unit test
  static bool skipNetworkCheck = false;

  /// Mengecek apakah error yang terjadi adalah network error
  static bool isNetworkError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    
    return errorMessage.contains('network') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('failed host lookup');
  }

  /// Mendapatkan pesan error yang user-friendly
  static String getErrorMessage(dynamic error) {
    if (isNetworkError(error)) {
      return "Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.";
    }
    
    return "Terjadi kesalahan. Silakan coba lagi.";
  }

  /// Cek apakah device terhubung ke internet
  /// Returns true jika terhubung, false jika tidak
  static Future<bool> hasInternetConnection() async {
    if (skipNetworkCheck) return true;

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
  }
}

