import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData? icon;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    this.icon,
  });

  factory AppStatusBadge.fromStatus(String status) {
    final s = status.toUpperCase().trim();
    switch (s) {
      case 'PENDING':
      case 'CHỜ XÁC NHẬN':
      case 'CHỜ DUYỆT':
        return const AppStatusBadge(
          label: 'Chờ duyệt',
          foregroundColor: AppColors.warning,
          backgroundColor: AppColors.warningLight,
          icon: Icons.hourglass_top_rounded,
        );
      case 'APPROVED':
      case 'ĐÃ XÁC NHẬN':
      case 'ĐÃ DUYỆT':
        return const AppStatusBadge(
          label: 'Đã duyệt',
          foregroundColor: AppColors.info,
          backgroundColor: AppColors.infoLight,
          icon: Icons.check_circle_outline_rounded,
        );
      case 'RENTING':
      case 'ONGOING':
      case 'ĐANG THUÊ':
        return const AppStatusBadge(
          label: 'Đang thuê',
          foregroundColor: AppColors.accent,
          backgroundColor: AppColors.accentContainer,
          icon: Icons.directions_car_rounded,
        );
      case 'COMPLETED':
      case 'HOÀN THÀNH':
        return const AppStatusBadge(
          label: 'Hoàn thành',
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successLight,
          icon: Icons.verified_rounded,
        );
      case 'CANCELLED':
      case 'REJECTED':
      case 'ĐÃ HUỶ':
      case 'TỪ CHỐI':
        return const AppStatusBadge(
          label: 'Đã huỷ',
          foregroundColor: AppColors.danger,
          backgroundColor: AppColors.dangerLight,
          icon: Icons.cancel_outlined,
        );
      default:
        return AppStatusBadge(
          label: status,
          foregroundColor: AppColors.textSecondary,
          backgroundColor: AppColors.borderSubtle,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: foregroundColor.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.dataLabel.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

