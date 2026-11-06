import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hệ chữ cao cấp của CarNow (tuân thủ Typography Tokens của UI/UX Pro Max):
/// - Sora: Dành cho Tiêu đề (Headlines, Titles) — Hình học vững chãi, hiện đại, thể thao.
/// - Inter: Dành cho Nội dung & UI Buttons — Dễ đọc tối đa ở mọi kích thước màn hình.
/// - JetBrains Mono: Nhãn chỉ số, giá tiền, mã đơn thuê — Chuẩn xác, rõ nét kiểu bảng điều khiển xe.
class AppTypography {
  AppTypography._();

  // ── Display & Headline ───────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      );

  static TextStyle get display => GoogleFonts.sora(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );

  static TextStyle get headline => GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  // ── Heading Aliases ──────────────────────────────────────────────────
  static TextStyle get headingLg => display;
  static TextStyle get headingMd => headline;
  static TextStyle get headingSm => titleLarge;

  static TextStyle get titleLarge => GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  // ── Body & Content ───────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textMuted,
      );

  // ── Action & Label ───────────────────────────────────────────────────
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
        color: Colors.white,
      );

  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: Colors.white,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => label;

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textMuted,
      );

  // ── Data & Monospace (Dashboard & Prices) ─────────────────────────────
  static TextStyle get priceLarge => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.primary,
      );

  static TextStyle get priceMedium => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get metricLarge => priceLarge;
  static TextStyle get metricMedium => priceMedium;
  static TextStyle get metricSmall => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get dataLabel => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: AppColors.accent,
      );
}
