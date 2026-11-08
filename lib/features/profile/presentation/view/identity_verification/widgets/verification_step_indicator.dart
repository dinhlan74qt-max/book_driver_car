import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class VerificationStepIndicator extends StatelessWidget {
  final int currentStep;
  final bool Function(int) isStepValid;
  final Function(int) onStepTapped;

  const VerificationStepIndicator({
    super.key,
    required this.currentStep,
    required this.isStepValid,
    required this.onStepTapped,
  });

  static const List<String> stepTitles = [
    'Thông tin',
    'Ảnh CCCD',
    'GPLX',
    'Chân dung',
    'Khẩn cấp',
    'Cam kết',
  ];

  static const List<IconData> stepIcons = [
    Icons.person_outline_rounded,
    Icons.badge_outlined,
    Icons.drive_eta_rounded,
    Icons.face_retouching_natural_rounded,
    Icons.emergency_outlined,
    Icons.verified_user_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final unselectedBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final progress = (currentStep + 1) / stepTitles.length;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // ── Linear Smooth Progress Track ────────────────────────────────
          Container(
            height: 3,
            width: double.infinity,
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E7ED),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      AppColors.accent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Horizontal Step Pills ───────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(stepTitles.length, (index) {
                final isActive = index == currentStep;
                final isDone = index < currentStep;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TapScale(
                    onTap: () {
                      if (index <= currentStep || isStepValid(currentStep)) {
                        onStepTapped(index);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                                colors: [primaryColor, const Color(0xFF1B4F72)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isActive
                            ? null
                            : (isDone
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : unselectedBg),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? primaryColor
                              : (isDone
                                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                  : borderColor),
                          width: isActive ? 1.2 : 1,
                        ),
                        boxShadow: isActive && !isDark
                            ? [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDone) ...[
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                          ] else ...[
                            Icon(
                              stepIcons[index],
                              size: 15,
                              color: isActive
                                  ? Colors.white
                                  : textSecondary.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            stepTitles[index],
                            style: AppTypography.caption.copyWith(
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12,
                              color: isActive
                                  ? Colors.white
                                  : (isDone ? const Color(0xFF10B981) : textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
