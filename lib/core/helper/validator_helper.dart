class ValidatorHelper {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^0\d{9}$').hasMatch(phone); // 10 số, bắt đầu bằng 0
  }

  static bool validateLicensePlate(String value) {
    return RegExp(r'^\d{2}[A-Z]{1,2}-?\d{3}\.?\d{2}$').hasMatch(value);
  }
}
