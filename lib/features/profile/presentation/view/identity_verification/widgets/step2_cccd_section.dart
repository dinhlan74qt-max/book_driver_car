import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/verification_image_picker_box.dart';
import 'package:flutter/material.dart';

class Step2CccdSection extends StatelessWidget {
  final String? cccdFrontImage;
  final String? cccdBackImage;
  final VoidCallback onPickFront;
  final VoidCallback onPickBack;
  final bool isReadOnly;

  const Step2CccdSection({
    super.key,
    required this.cccdFrontImage,
    required this.cccdBackImage,
    required this.onPickFront,
    required this.onPickBack,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

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
                    colors: [Color(0xFF0E3A5D), AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
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
                      'Bước 2: Ảnh chụp CCCD / CMND',
                      style: AppTypography.titleMedium.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Chụp rõ nét 2 mặt giấy tờ để AI nhận diện tự động.',
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

        // ── Photo Guidelines Banner ────────────────────────────────────────
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
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF0E3A5D),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quy chuẩn chụp ảnh đạt duyệt 100%:',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0E3A5D),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Đặt giấy tờ trên mặt phẳng, đủ ánh sáng tự nhiên.\n'
                      '• Không chụp lóa đèn flash, không che ngón tay vào góc thẻ.\n'
                      '• Toàn bộ thông tin, số CCCD và mã QR phải sắc nét.',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF1B4F72),
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

        const SizedBox(height: 20),

        VerificationImagePickerBox(
          label: 'Ảnh mặt trước CCCD *',
          imagePath: cccdFrontImage,
          documentIcon: Icons.badge_outlined,
          emptySubtitle: 'Chụp chính diện mặt trước thẻ CCCD',
          isReadOnly: isReadOnly,
          onPick: onPickFront,
        ),

        const SizedBox(height: 20),

        VerificationImagePickerBox(
          label: 'Ảnh mặt sau CCCD *',
          imagePath: cccdBackImage,
          documentIcon: Icons.fingerprint_rounded,
          emptySubtitle: 'Chụp rõ nét mặt sau, mã QR và dải chip',
          isReadOnly: isReadOnly,
          onPick: onPickBack,
        ),
      ],
    );
  }
}
