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

  factory AppStatusBadge.fromStatus(String? status) {
    if (status == null ||
        status.trim().isEmpty ||
        status.trim().toUpperCase() == 'NULL') {
      return const AppStatusBadge(
        label: 'Đang chờ duyệt',
        foregroundColor: AppColors.warning,
        backgroundColor: AppColors.warningLight,
        icon: Icons.hourglass_top_rounded,
      );
    }

    final s = status.toUpperCase().trim();
    switch (s) {
      case 'AVAILABLE':
      case 'SẴN SÀNG':
        return const AppStatusBadge(
          label: 'Khả dụng',
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successLight,
          icon: Icons.check_circle_rounded,
        );
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
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successLight,
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
      case 'ĐÃ HUỶ':
        return const AppStatusBadge(
          label: 'Đã huỷ',
          foregroundColor: AppColors.danger,
          backgroundColor: AppColors.dangerLight,
          icon: Icons.cancel_outlined,
        );
      case 'REJECTED':
      case 'DENIED':
      case 'TỪ CHỐI':
        return const AppStatusBadge(
          label: 'Từ chối',
          foregroundColor: AppColors.danger,
          backgroundColor: AppColors.dangerLight,
          icon: Icons.cancel_rounded,
        );
      default:
        return AppStatusBadge(
          label: status,
          foregroundColor: AppColors.textSecondary,
          backgroundColor: AppColors.borderSubtle,
        );
    }
  }

  /// Factory riêng chuyên dụng cho xe sở hữu / đội xe (Owner Fleet)
  factory AppStatusBadge.fromVehicleStatus(String? status) {
    if (status == null ||
        status.trim().isEmpty ||
        status.trim().toUpperCase() == 'NULL') {
      return const AppStatusBadge(
        label: 'Đang chờ duyệt',
        foregroundColor: AppColors.warning,
        backgroundColor: AppColors.warningLight,
        icon: Icons.hourglass_top_rounded,
      );
    }

    final s = status.toUpperCase().trim();
    switch (s) {
      // 1. Xe đã được duyệt / Sẵn sàng đón khách
      case 'AVAILABLE':
      case 'APPROVED':
      case 'VERIFIED':
      case 'ACTIVE':
      case 'SẴN SÀNG':
      case 'ĐÃ DUYỆT':
      case 'DA_DUYET':
        return const AppStatusBadge(
          label: 'Đã duyệt',
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successLight,
          icon: Icons.check_circle_rounded,
        );

      // 2. Xe đang chờ kiểm duyệt
      case 'PENDING':
      case 'WAITING':
      case 'IN_REVIEW':
      case 'CHỜ DUYỆT':
      case 'ĐANG CHỜ DUYỆT':
      case 'CHO_DUYET':
        return const AppStatusBadge(
          label: 'Đang chờ duyệt',
          foregroundColor: AppColors.warning,
          backgroundColor: AppColors.warningLight,
          icon: Icons.hourglass_top_rounded,
        );

      // 3. Xe chưa được duyệt / Bị từ chối
      case 'REJECTED':
      case 'DENIED':
      case 'UNAPPROVED':
      case 'NOT_APPROVED':
      case 'CHƯA DUYỆT':
      case 'CHƯA ĐƯỢC DUYỆT':
      case 'TỪ CHỐI':
      case 'TU_CHOI':
        return const AppStatusBadge(
          label: 'Chưa được duyệt',
          foregroundColor: AppColors.danger,
          backgroundColor: AppColors.dangerLight,
          icon: Icons.cancel_rounded,
        );

      // 4. Xe đang có khách thuê
      case 'RENTING':
      case 'RENTED':
      case 'BUSY':
      case 'ONGOING':
      case 'ĐANG CHO THUÊ':
      case 'ĐANG THUÊ':
        return const AppStatusBadge(
          label: 'Đang cho thuê',
          foregroundColor: AppColors.info,
          backgroundColor: AppColors.infoLight,
          icon: Icons.directions_car_rounded,
        );

      // 5. Xe tạm ẩn / khóa hoạt động
      case 'UNAVAILABLE':
      case 'BLOCKED':
      case 'LOCKED':
      case 'INACTIVE':
      case 'TẠM ẨN':
      case 'TAM_AN':
        return const AppStatusBadge(
          label: 'Tạm ẩn',
          foregroundColor: AppColors.textSecondary,
          backgroundColor: AppColors.borderSubtle,
          icon: Icons.visibility_off_rounded,
        );

      default:
        return AppStatusBadge(
          label: status.isEmpty ? 'Chưa rõ' : status,
          foregroundColor: AppColors.textSecondary,
          backgroundColor: AppColors.borderSubtle,
          icon: Icons.info_outline_rounded,
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

