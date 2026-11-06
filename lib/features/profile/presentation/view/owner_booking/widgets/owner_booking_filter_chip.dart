import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class OwnerBookingFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? badgeColor;
  final VoidCallback onTap;

  const OwnerBookingFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (badgeColor != null ? badgeColor!.withValues(alpha: 0.15) : surfaceColor),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (badgeColor ?? borderColor),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? (isDark ? AppColors.darkBackground : Colors.white)
                : (badgeColor ?? textPrimary),
          ),
        ),
      ),
    );
  }
}
