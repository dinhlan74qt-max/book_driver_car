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
  static const Color backgroundDark = Color(0xFF0F1115);

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
  // ── Error Toast ─────────────────────────────────────
  static const Color toastErrorBackground = Color(0xFFFFEBEE);
  static const Color toastErrorBorder = Color(0xFFEF9A9A);
  static const Color toastErrorShadow = Color(0x14C62828);
  static const Color toastErrorIconBg = Color(0xFFFFCDD2);
  static const Color toastErrorContent = Color(0xFFC62828);
  // -- Success Toast -------------------------------------------------------
  static const Color toastSuccessBackground = Color(0xFFE8F5E9);
  static const Color toastSuccessBorder = Color(0xFFA5D6A7);
  static const Color toastSuccessShadow = Color(0x142E7D32);
  static const Color toastSuccessIconBg = Color(0xFFC8E6C9);
  static const Color toastSuccessContent = Color(0xFF2E7D32);
  // -- Warning Toast -------------------------------------------------------
  static const Color toastWarningBackground = Color(0xFFFFF3E0);
  static const Color toastWarningBorder = Color(0xFFFFCC80);
  static const Color toastWarningShadow = Color(0x14EF6C00);
  static const Color toastWarningIconBg = Color(0xFFFFE0B2);
  static const Color toastWarningContent = Color(0xFFEF6C00);
  // -- Info Toast ----------------------------------------------------------
  static const Color toastInfoBackground = Color(0xFFE3F2FD);
  static const Color toastInfoBorder = Color(0xFF90CAF9);
  static const Color toastInfoShadow = Color(0x141565C0);
  static const Color toastInfoIconBg = Color(0xFFBBDEFB);
  static const Color toastInfoContent = Color(0xFF1565C0);
  // -- Toast shared -------------------------------------------------------
  static const Color toastText = Color(0xFF322E28);
}
