import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:flutter/material.dart';

class HomeEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onReset;

  const HomeEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Xoá bộ lọc',
            variant: AppButtonVariant.outline,
            height: 42,
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}
