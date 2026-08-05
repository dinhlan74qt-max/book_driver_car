class ApiConstants {
  static const String baseUrl = _devicePhysical;

  // Android Emulator
  static const String _androidEmulator = "http://10.0.2.2:8080";

  // iOS Simulator
  static const String _iosSimulator = "http://localhost:8080";

  // Thiết bị thật (đổi theo IP LAN máy tính của bạn, dùng ipconfig để xem)
  // Đã trỏ thẳng lên server online: nsopro.site
  static const String _devicePhysical = "http://nsopro.site:8080";

  // Endpoint cụ thể
  static const String sendOtp = "$baseUrl/api/auth/register/send-otp";
  static const String verifyOtp = "$baseUrl/api/auth/register/verify-otp";
  static const String login = "$baseUrl/api/auth/login";
  static const String vehicles = "$baseUrl/api/vehicles";
}
