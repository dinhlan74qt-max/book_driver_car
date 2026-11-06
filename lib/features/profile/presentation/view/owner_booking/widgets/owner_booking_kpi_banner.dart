import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class OwnerBookingKpiBanner extends StatelessWidget {
  final int totalBookings;
  final int pendingCount;
  final num totalRevenue;
  final String Function(num) formatPrice;

  const OwnerBookingKpiBanner({
    super.key,
    required this.totalBookings,
    required this.pendingCount,
    required this.totalRevenue,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final accentWarm = isDark ? AppColors.darkAccent : AppColors.accentWarm;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.divider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppColors.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildKpiItem(
              label: 'Tổng đơn',
              value: '$totalBookings',
              icon: Icons.receipt_long_rounded,
              iconColor: primaryColor,
              labelColor: textSecondary,
              valueColor: textPrimary,
            ),
          ),
          Container(width: 1, height: 36, color: dividerColor),
          Expanded(
            child: _buildKpiItem(
              label: 'Chờ duyệt',
              value: '$pendingCount',
              icon: Icons.pending_actions_rounded,
              iconColor: accentWarm,
              labelColor: textSecondary,
              valueColor: pendingCount > 0 ? (isDark ? AppColors.darkAccent : AppColors.accentWarm) : textPrimary,
              isAlert: pendingCount > 0,
            ),
          ),
          Container(width: 1, height: 36, color: dividerColor),
          Expanded(
            child: _buildKpiItem(
              label: 'Ước tính thu',
              value: '${formatPrice(totalRevenue)}đ',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: isDark ? const Color(0xFF81C69A) : AppColors.success,
              labelColor: textSecondary,
              valueColor: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color labelColor,
    required Color valueColor,
    bool isAlert = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.priceMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
