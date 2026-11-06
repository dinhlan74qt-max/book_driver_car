import 'package:flutter/material.dart';

/// Bảng màu chuẩn mực của CarNow - Phong cách: MODERN MOBILITY (DEEP RICH NAVY & BOLD AMBER ORANGE)
/// - Chiến lược: DUAL THEME – LIGHT MODE + DARK MODE
/// - Tinh thần: Đậm đà, Sang trọng, Hiện đại, Tương phản cao và chiều sâu sắc nét
abstract class AppColors {
  // ── Light Theme Tokens (Deep Rich Navy & Bold Amber Orange) ───────────────
  static const Color primary = Color(
    0xFF0E3A5D,
  ); // Deep Rich Ocean Navy (Đậm đà, sắc nét)
  static const Color primaryContainer = Color(0xFFDCEAF5); // Soft Ice Blue
  static const Color primaryDark = Color(0xFF09253A); // Midnight Dark Navy
  static const Color primaryLight = Color(0xFF1B4F72); // Classic Ocean Navy
  static const Color luxuryNavy = Color(0xFF0E3A5D); // Alias

  static const Color secondary = Color(0xFF4A5C6F); // Deep Slate Blue
  static const Color secondaryContainer = Color(0xFFD9E1E8);

  static const Color accent = Color(
    0xFFE86000,
  ); // Bold Rich Amber Orange (Đậm và ấm)
  static const Color accentLight = Color(0xFFFF7A00);
  static const Color accentWarm = Color(0xFFE86000);
  static const Color accentContainer = Color(0xFFFFEAD4);

  static const Color background = Color(
    0xFFFAFBFC,
  ); // Ghost White Canvas (Gần như màu trắng, chỉ dịu hơn một chút để phân biệt hoàn hảo với Card trắng)
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(
    0xFFF3F5F8,
  ); // Very Light Crisp Surface
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF7F9FB);

  static const Color textPrimary = Color(
    0xFF0F1216,
  ); // Deep Bold Charcoal Black
  static const Color textSecondary = Color(
    0xFF525C68,
  ); // Rich Slate Gray (Đậm hơn, rõ ràng)
  static const Color textTertiary = Color(0xFF8A94A0);
  static const Color textMuted = Color(0xFF8A94A0);
  static const Color textDisabled = Color(0xFFBCC4CE);

  static const Color border = Color(
    0xFFE6EBF1,
  ); // Subtle Defined Hairline Border
  static const Color borderLight = Color(0xFFE6EBF1);
  static const Color borderSubtle = Color(0xFFEFF2F6);
  static const Color divider = Color(0xFFEBEEF3);

  static const Color success = Color(0xFF177A4C); // Rich Forest Emerald
  static const Color successLight = Color(0xFFE4F4EC);
  static const Color warning = Color(0xFFD96000); // Rich Amber
  static const Color warningLight = Color(0xFFFFF0E0);
  static const Color danger = Color(0xFFC73434); // Rich Crimson Red
  static const Color dangerLight = Color(0xFFFDE8E8);
  static const Color info = Color(0xFF0E3A5D);
  static const Color infoLight = Color(0xFFDCEAF5);

  // ── Dark Theme Tokens (Deep Midnight Asphalt & Deep Surface Navy) ────────
  static const Color darkPrimary = Color(0xFF4B9CD3); // Bold Sky Blue
  static const Color darkPrimaryContainer = Color(0xFF12283C);
  static const Color darkSecondary = Color(0xFF7E8C9E);
  static const Color darkAccent = Color(0xFFF57C00); // Deep Amber Orange
  static const Color darkBackground = Color(0xFF0B0E13); // Deep Midnight Void
  static const Color darkSurface = Color(0xFF151C26); // Deep Surface Navy
  static const Color darkSurfaceSecondary = Color(0xFF1D2633);
  static const Color darkTextPrimary = Color(0xFFF2F4F7); // Crisp Lane White
  static const Color darkTextSecondary = Color(0xFF94A0B2); // Steel Mist
  static const Color darkTextMuted = Color(0xFF657182);
  static const Color darkBorder = Color(0xFF263345); // Defined Hairline
  static const Color darkSuccess = Color(0xFF38B87C);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkDanger = Color(0xFFF05252);

  // ── Dark Aliases (Backward compatible) ──────────────────────────────────
  static const Color asphalt = Color(0xFF0B0E13);
  static const Color backgroundDark = Color(0xFF0B0E13);
  static const Color surfaceNavy = Color(0xFF151C26);
  static const Color hairline = Color(0xFF263345);
  static const Color headlightAmber = Color(0xFFF59E0B);
  static const Color taillightCoral = Color(0xFFF05252);
  static const Color laneWhite = Color.fromARGB(255, 242, 244, 247);
  static const Color steelMist = Color(0xFF94A0B2);
  static const Color laneMarkingDim = Color(0xFF2D3B4F);

  // ── Page Accents (Onboarding / Features) ───────────────────────────────
  static const List<Color> pageAccents = [
    headlightAmber,
    Color(0xFF2E9E6B), // xanh mint đậm
    Color(0xFF2B6CB0), // xanh dương đậm
    taillightCoral, // đỏ đèn hậu
  ];

  // ── Elevation & Shadow Tokens ──────────────────────────────────────────
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0F09253A), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x1609253A), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x2009253A), blurRadius: 28, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> shadowGlass = [
    BoxShadow(color: Color(0x140E3A5D), blurRadius: 20, offset: Offset(0, 8)),
  ];

  // ── Shimmer & Skeleton Tokens ──────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFDCE1E8);
  static const Color shimmerHighlight = Color(0xFFEEF2F7);

  static const Color darkShimmerBase = Color(0xFF1D2633);
  static const Color darkShimmerHighlight = Color(0xFF283446);

  // ── Toast Colors ───────────────────────────────────────────────────────
  static const Color toastErrorBackground = Color(0xFFFDE8E8);
  static const Color toastErrorBorder = Color(0xFFF8B4B4);
  static const Color toastErrorShadow = Color(0x1EC73434);
  static const Color toastErrorIconBg = Color(0xFFFCD0D0);
  static const Color toastErrorContent = Color(0xFFC73434);

  static const Color toastSuccessBackground = Color(0xFFE4F4EC);
  static const Color toastSuccessBorder = Color(0xFF8CE0B5);
  static const Color toastSuccessShadow = Color(0x1E177A4C);
  static const Color toastSuccessIconBg = Color(0xFFC4EED7);
  static const Color toastSuccessContent = Color(0xFF177A4C);

  static const Color toastWarningBackground = Color(0xFFFFF0E0);
  static const Color toastWarningBorder = Color(0xFFFFC085);
  static const Color toastWarningShadow = Color(0x1ED96000);
  static const Color toastWarningIconBg = Color(0xFFFFDAB3);
  static const Color toastWarningContent = Color(0xFFD96000);

  static const Color toastInfoBackground = Color(0xFFDCEAF5);
  static const Color toastInfoBorder = Color(0xFF85B8DE);
  static const Color toastInfoShadow = Color(0x1E0E3A5D);
  static const Color toastInfoIconBg = Color(0xFFBAD8ED);
  static const Color toastInfoContent = Color(0xFF0E3A5D);

  static const Color toastText = Color(0xFF0F1216);
}
