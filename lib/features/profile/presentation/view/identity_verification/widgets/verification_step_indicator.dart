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
    'Cá nhân',
    'Ảnh CCCD',
    'GPLX',
    'Selfie',
    'Khẩn cấp',
    'Cam kết',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final unselectedBg = isDark ? AppColors.darkSurface : AppColors.surfacePrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(stepTitles.length, (index) {
            final isActive = index == currentStep;
            final isDone = index < currentStep;

            return Row(
              children: [
                TapScale(
                  onTap: () {
                    if (index <= currentStep || isStepValid(currentStep)) {
                      onStepTapped(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? primaryColor
                          : (isDone ? primaryColor.withValues(alpha: 0.15) : unselectedBg),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? primaryColor
                            : (isDone ? primaryColor.withValues(alpha: 0.4) : borderColor),
                      ),
                      boxShadow: isActive && !isDark
                          ? [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        if (isDone)
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(Icons.check_rounded, color: primaryColor, size: 14),
                          ),
                        Text(
                          '${index + 1}. ${stepTitles[index]}',
                          style: AppTypography.caption.copyWith(
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                            color: isActive
                                ? (isDark ? AppColors.darkBackground : Colors.white)
                                : (isDone ? primaryColor : textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < stepTitles.length - 1)
                  Container(
                    width: 14,
                    height: 1.5,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: isDone ? primaryColor.withValues(alpha: 0.4) : borderColor,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
