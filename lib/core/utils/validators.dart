class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email wajib diisi";
    }

    if (!value.contains("@")) {
      return "Format email tidak valid";
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password wajib diisi";
    }

    if (value.length < 6) {
      return "Minimal 6 karakter";
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Nama wajib diisi";
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Nomor telepon wajib diisi";
    }

    if (value.length < 10) {
      return "Nomor tidak valid";
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return "Konfirmasi password wajib diisi";
    }

    if (value != password) {
      return "Password tidak sama";
    }

    return null;
  }
}
