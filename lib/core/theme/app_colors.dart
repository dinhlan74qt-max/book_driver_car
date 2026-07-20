import 'package:flutter/material.dart';
abstract class AppColors {
   static const primary = Color(0xFF1B4F72);   
  static const accent = Color(0xFFFF7A00);    
  static const success = Color(0xFF1E8E5A);
  static const danger = Color(0xFFD64545);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F6F8);
  static const border = Color(0xFFE3E5E8);
  static const textPrimary = Color(0xFF1A1D1F);
  static const textSecondary = Color(0xFF6F767E);
  static const textMuted = Color(0xFFA6ABB0);

  /// Nền chính — nhựa đường lúc nửa đêm.
  static const Color asphalt = Color(0xFF12141C);

  /// Nền bề mặt (bottom sheet, card) — xanh navy đậm.
  static const Color surfaceNavy = Color(0xFF1B2030);

  /// Đường viền / chia tách rất mờ trên nền tối.
  static const Color hairline = Color(0xFF2A3040);

  /// Màu nhấn chính — ánh đèn pha halogen ấm.
  static const Color headlightAmber = Color(0xFFFFB13C);

  /// Màu nhấn phụ — đèn hậu, dùng rất tiết chế cho cảnh báo/CTA nhẹ.
  static const Color taillightCoral = Color(0xFFFF6B5B);

  /// Chữ chính trên nền tối.
  static const Color laneWhite = Color(0xFFF4F5F9);

  /// Chữ phụ, mô tả.
  static const Color steelMist = Color(0xFF8891A6);

  /// Vạch kẻ đường (dùng cho road indicator ở trạng thái chưa active).
  static const Color laneMarkingDim = Color(0xFF3A4058);

  static const List<Color> pageAccents = [
    headlightAmber,
    Color(0xFF7FD1AE), // xanh mint — tự do, đường dài
    Color(0xFF7BA6FF), // xanh dương — nhanh gọn, số hoá
    taillightCoral, // đỏ đèn hậu — an toàn, bảo vệ
  ];
}
