import 'dart:convert';
import 'package:book_drive_car/core/features/auth/domain/entities/user_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';


@lazySingleton
class UserLocalStorage {
  static const String _token = 'auth_token';
  static const String _tokenType = 'auth_token_type';
  static const String _user = 'auth_user';
  static const String _welcomeSeen = 'welcome_seen';

  /// Lưu toàn bộ thông tin đăng nhập (gọi ngay sau khi login thành công)
  Future<void> saveSession({
    required String token,
    required String tokenType,
    required UserEntity user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_token, token);
    await prefs.setString(_tokenType, tokenType);
    await prefs.setString(_user, jsonEncode(_userToMap(user)));
  }

  Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeSeen, true);
  }

  Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeSeen) ?? false;
  }

  /// Lấy token hiện tại (dùng để gắn vào header Authorization khi gọi API khác)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token);
  }

  Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenType);
  }

  Future<String?> getAuthHeader() async {
    final token = await getToken();
    final tokenType = await getTokenType();
    if (token == null || tokenType == null) return null;
    return "$tokenType $token"; // ví dụ: "Bearer eyJhbGciOi..."
  }

  /// Lấy toàn bộ thông tin user đã lưu (null nếu chưa đăng nhập)
  Future<UserEntity?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_user);
    if (raw == null) return null;
    return _userFromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Kiểm tra nhanh xem đã đăng nhập chưa (dùng ở SplashScreen để quyết định
  /// điều hướng vào HomeScreen hay LoginScreen)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Cập nhật một phần thông tin user (ví dụ sau khi user sửa profile,
  /// thêm cccd/address/avatar mà lúc đăng nhập đang null)
  Future<void> updateUser({
    String? fullname,
    String? phone,
    String? cccd,
    String? address,
    String? avatar,
  }) async {
    final current = await getUser();
    if (current == null) return; // chưa đăng nhập thì không có gì để sửa

    final updated = UserEntity(
      id: current.id,
      fullname: fullname ?? current.fullname,
      email: current.email, // email không cho sửa qua hàm này (thường phải xác thực riêng)
      phone: phone ?? current.phone,
      cccd: cccd ?? current.cccd,
      address: address ?? current.address,
      avatar: avatar ?? current.avatar,
      role: current.role,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_user, jsonEncode(_userToMap(updated)));
  }

  /// Xóa toàn bộ session (dùng khi Logout)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_token);
    await prefs.remove(_tokenType);
    await prefs.remove(_user);
  }

  //////////////////// Helper convert UserEntity <-> Map ////////////////////
  // SharedPreferences chỉ lưu được String/int/bool/double/List<String>,
  // không lưu trực tiếp được object, nên phải convert qua Map rồi jsonEncode.

  Map<String, dynamic> _userToMap(UserEntity user) {
    return {
      'id': user.id,
      'fullname': user.fullname,
      'email': user.email,
      'phone': user.phone,
      'cccd': user.cccd,
      'address': user.address,
      'avatar': user.avatar,
      'role': user.role,
    };
  }

  UserEntity _userFromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'],
      fullname: map['fullname'],
      email: map['email'],
      phone: map['phone'],
      cccd: map['cccd'],
      address: map['address'],
      avatar: map['avatar'],
      role: map['role'],
    );
  }
}
