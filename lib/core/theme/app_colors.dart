import 'package:flutter/material.dart';
import 'package:book_drive_car/core/theme/theme_controller.dart';

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

  // ── High-Contrast Mobility Tokens (Dual Theme) ───────────────────────────
  static const Color canvasLight = Color(0xFFF1F5F9); // Crisp Slate 100
  static const Color canvasDark = Color(0xFF0B0E14); // Deep Midnight 950

  static const Color cardLight = Color(0xFFFFFFFF); // Pure White
  static const Color cardDark = Color(0xFF1E293B); // Rich Slate Navy 800

  static const Color cardSubtleLight = Color(0xFFF8FAFC); // Slate 50
  static const Color cardSubtleDark = Color(0xFF0F172A); // Slate 900

  static const Color cardBorderLight = Color(0xFFE2E8F0); // Defined Slate 200
  static const Color cardBorderDark = Color(0xFF334155); // Defined Slate 700

  static const Color textMainLight = Color(0xFF0F172A); // High-contrast Slate 900
  static const Color textMainDark = Color(0xFFF8FAFC); // Crisp Slate 50

  static const Color textSubLight = Color(0xFF475569); // Slate 600
  static const Color textSubDark = Color(0xFF94A3B8); // Slate 400

  static const Color textMutedSlate = Color(0xFF64748B); // Slate 500

  // ── Tag & Accent Pill Tokens ──────────────────────────────────────────────
  static const Color tagTextLight = Color(0xFF0284C7); // Sky 600
  static const Color tagTextDark = Color(0xFF38BDF8); // Sky 400
  static const Color tagBgLight = Color(0xFFE0F2FE); // Sky 100
  static const Color tagBgDark = Color(0xFF0C4A6E); // Sky 900

  // ── Adaptive Dynamic Helpers (Native ThemeExtension & Fallbacks) ─────────
  static CarNowThemeColors of(BuildContext context) {
    return Theme.of(context).extension<CarNowThemeColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? CarNowThemeColors.dark
            : CarNowThemeColors.light);
  }

  static BuildContext? _ctx(dynamic a, BuildContext? b) =>
      a is BuildContext ? a : b;
  static bool? _dark(dynamic a) => a is bool ? a : null;

  static Color getBackground([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).background;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? canvasDark
        : canvasLight;
  }

  static Color getSurface([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).surface;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? cardDark
        : cardLight;
  }

  static Color getSurfaceSubtle([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).surfaceSubtle;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? cardSubtleDark
        : cardSubtleLight;
  }

  static Color getSurfaceSecondary([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).surfaceSecondary;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? darkSurfaceSecondary
        : surfaceSecondary;
  }

  static Color getBorder([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).border;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? cardBorderDark
        : cardBorderLight;
  }

  static Color getPrimary([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).primary;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? tagTextDark
        : primary;
  }

  static Color getPrimaryContainer([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).primaryContainer;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? tagBgDark
        : tagBgLight;
  }

  static Color getTextPrimary([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).textPrimary;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? textMainDark
        : textMainLight;
  }

  static Color getTextSecondary([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).textSecondary;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? textSubDark
        : textSubLight;
  }

  static Color getTextMuted([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).textMuted;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? darkTextMuted
        : textTertiary;
  }

  static Color getTagText([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).tagText;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? tagTextDark
        : tagTextLight;
  }

  static Color getTagBg([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).tagBg;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? tagBgDark
        : tagBgLight;
  }

  static Color getDivider([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).divider;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? cardBorderDark
        : divider;
  }

  static Color getWarning([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).warning;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? darkWarning
        : warning;
  }

  static Color getSuccess([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).success;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? darkSuccess
        : success;
  }

  static Color getDanger([dynamic isDarkOrContext, BuildContext? context]) {
    final ctx = _ctx(isDarkOrContext, context);
    if (ctx != null) return of(ctx).danger;
    return (_dark(isDarkOrContext) ?? themeController.isDarkMode)
        ? darkDanger
        : danger;
  }

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

/// ThemeExtension hỗ trợ nội suy màu sắc 60fps mượt mà bằng AnimatedTheme của Flutter
@immutable
class CarNowThemeColors extends ThemeExtension<CarNowThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceSecondary;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color primaryContainer;
  final Color tagText;
  final Color tagBg;
  final Color divider;
  final Color warning;
  final Color success;
  final Color danger;

  const CarNowThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceSecondary,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primaryContainer,
    required this.tagText,
    required this.tagBg,
    required this.divider,
    required this.warning,
    required this.success,
    required this.danger,
  });

  static const CarNowThemeColors light = CarNowThemeColors(
    background: AppColors.canvasLight,
    surface: AppColors.cardLight,
    surfaceSubtle: AppColors.cardSubtleLight,
    surfaceSecondary: AppColors.surfaceSecondary,
    border: AppColors.cardBorderLight,
    textPrimary: AppColors.textMainLight,
    textSecondary: AppColors.textSubLight,
    textMuted: AppColors.textTertiary,
    primary: AppColors.primary,
    primaryContainer: AppColors.tagBgLight,
    tagText: AppColors.tagTextLight,
    tagBg: AppColors.tagBgLight,
    divider: AppColors.divider,
    warning: AppColors.warning,
    success: AppColors.success,
    danger: AppColors.danger,
  );

  static const CarNowThemeColors dark = CarNowThemeColors(
    background: AppColors.canvasDark,
    surface: AppColors.cardDark,
    surfaceSubtle: AppColors.cardSubtleDark,
    surfaceSecondary: AppColors.darkSurfaceSecondary,
    border: AppColors.cardBorderDark,
    textPrimary: AppColors.textMainDark,
    textSecondary: AppColors.textSubDark,
    textMuted: AppColors.darkTextMuted,
    primary: AppColors.tagTextDark,
    primaryContainer: AppColors.tagBgDark,
    tagText: AppColors.tagTextDark,
    tagBg: AppColors.tagBgDark,
    divider: AppColors.cardBorderDark,
    warning: AppColors.darkWarning,
    success: AppColors.darkSuccess,
    danger: AppColors.darkDanger,
  );

  @override
  CarNowThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSubtle,
    Color? surfaceSecondary,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? primaryContainer,
    Color? tagText,
    Color? tagBg,
    Color? divider,
    Color? warning,
    Color? success,
    Color? danger,
  }) {
    return CarNowThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      tagText: tagText ?? this.tagText,
      tagBg: tagBg ?? this.tagBg,
      divider: divider ?? this.divider,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  CarNowThemeColors lerp(ThemeExtension<CarNowThemeColors>? other, double t) {
    if (other is! CarNowThemeColors) return this;
    return CarNowThemeColors(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSubtle:
          Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ?? surfaceSubtle,
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t) ??
              surfaceSecondary,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t) ??
              primaryContainer,
      tagText: Color.lerp(tagText, other.tagText, t) ?? tagText,
      tagBg: Color.lerp(tagBg, other.tagBg, t) ?? tagBg,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      success: Color.lerp(success, other.success, t) ?? success,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
    );
  }
}
