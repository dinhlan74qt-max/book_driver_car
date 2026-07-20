import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hệ chữ của CarNow:
/// - Sora  : tiêu đề — hình học, chắc chắn, gợi cảm giác kỹ thuật/tốc độ.
/// - Inter : nội dung mô tả — dễ đọc ở cỡ nhỏ.
/// - JetBrains Mono : nhãn dữ liệu kiểu bảng đồng hồ (VD "24/7", "500+ xe").
class AppTypography {
  AppTypography._();

  static TextStyle get display => GoogleFonts.sora(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.laneWhite,
        letterSpacing: -0.4,
      );

  static TextStyle get headline => GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.laneWhite,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.steelMist,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.asphalt,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.steelMist,
      );

  static TextStyle get dataLabel => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: AppColors.headlightAmber,
      );
}
