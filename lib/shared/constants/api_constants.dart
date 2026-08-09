class ApiConstants {
  static const String baseUrl = _devicePhysical;

  // Thiết bị thật (đổi theo IP LAN máy tính của bạn, dùng ipconfig để xem)
  static const String _devicePhysical = "http://nsopro.site";

  // Endpoint cụ thể
  static const String sendOtp = "$baseUrl/api/auth/register/send-otp";
  static const String verifyOtp = "$baseUrl/api/auth/register/verify-otp";
  static const String login = "$baseUrl/api/auth/login";
  static const String vehicles = "$baseUrl/api/vehicles";
  static const String myVehicles = "$baseUrl/api/vehicles/my-vehicles";
  static const String myWallet = "$baseUrl/api/my-wallet";
  static const String deposits = "$baseUrl/api/my-wallet/deposit";
  static const String bookings = "$baseUrl/api/booking";
  static const String bookingStatus = "$baseUrl/api/booking/status";
}
