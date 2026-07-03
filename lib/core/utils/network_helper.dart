class NetworkHelper {
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
}
