import 'package:book_drive_car/core/theme/app_colors.dart';
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildKpiItem(
              label: 'Tổng đơn',
              value: '$totalBookings',
              icon: Icons.receipt_long_rounded,
              iconColor: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildKpiItem(
              label: 'Chờ duyệt',
              value: '$pendingCount',
              icon: Icons.pending_actions_rounded,
              iconColor: const Color(0xFFFFA000),
              isAlert: pendingCount > 0,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildKpiItem(
              label: 'Ước tính thu',
              value: '${formatPrice(totalRevenue)} đ',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xFF2E7D32),
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
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isAlert ? const Color(0xFFD32F2F) : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
