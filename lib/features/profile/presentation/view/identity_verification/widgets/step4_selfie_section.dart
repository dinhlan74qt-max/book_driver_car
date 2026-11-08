import 'dart:io';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class Step4SelfieSection extends StatelessWidget {
  final String? selfieImage;
  final VoidCallback onPickSelfie;
  final bool isReadOnly;

  const Step4SelfieSection({
    super.key,
    required this.selfieImage,
    required this.onPickSelfie,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    final hasSelfie = selfieImage != null && selfieImage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Card ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E3A5D), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bước 4: Ảnh chân dung khuôn mặt',
                      style: AppTypography.titleMedium.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Chụp trực tiếp để hệ thống đối sánh sinh trắc học với CCCD.',
                      style: AppTypography.caption.copyWith(
                        color: textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Notice Box ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkPrimary.withValues(alpha: 0.12)
                : const Color(0xFFDCEAF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.darkPrimary.withValues(alpha: 0.25)
                  : const Color(0xFFBACFDE),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.center_focus_strong_rounded,
                color: Color(0xFF0E3A5D),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hướng dẫn chụp chân dung:',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0E3A5D),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Đưa khuôn mặt vào giữa khung tròn, nhìn thẳng vào ống kính.\n'
                      '• Không đeo khẩu trang, mũ hoặc kính râm tối màu.\n'
                      '• Đảm bảo không gian đủ ánh sáng, không bị ngược sáng.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF1B4F72),
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ── Center Selfie Preview or Camera Button ──────────────────────────
        Center(
          child: Column(
            children: [
              TapScale(
                onTap: isReadOnly ? null : onPickSelfie,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasSelfie
                          ? const Color(0xFF10B981)
                          : AppColors.primary,
                      width: hasSelfie ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (hasSelfie
                                ? const Color(0xFF10B981)
                                : AppColors.primary)
                            .withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasSelfie
                        ? (selfieImage!.startsWith('http')
                            ? Image.network(selfieImage!, fit: BoxFit.cover)
                            : Image.file(File(selfieImage!), fit: BoxFit.cover))
                        : Container(
                            color: isDark
                                ? AppColors.darkSurfaceSecondary
                                : AppColors.surfaceSecondary,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  size: 44,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Chạm để chụp',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (hasSelfie) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ảnh chân dung hợp lệ',
                      style: TextStyle(
                        color: const Color(0xFF10B981),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (!isReadOnly) ...[
                  const SizedBox(height: 8),
                  TapScale(
                    onTap: onPickSelfie,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceSecondary
                            : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 16, color: textPrimary),
                          const SizedBox(width: 6),
                          Text(
                            'Chụp lại ảnh khác',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'Nhấn vào vòng tròn trên để mở camera chụp ảnh',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
