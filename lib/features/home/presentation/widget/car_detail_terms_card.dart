import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CarDetailTermsCard extends StatelessWidget {
  const CarDetailTermsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppColors.shadowSm,
      ),
      child: Column(
        children: [
          const _TermRow(
            icon: Icons.badge_outlined,
            title: 'Giấy tờ bắt buộc',
            desc: 'GPLX + CCCD gắn chip đối chiếu khi nhận xe.',
          ),
          Divider(height: 24, color: borderColor),
          const _TermRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Thanh toán tiền tại app',
            desc: 'Vui lòng nạp tiền và thanh toán chuyến đi ngay tại app.',
          ),
          Divider(height: 24, color: borderColor),
          const _TermRow(
            icon: Icons.local_gas_station_outlined,
            title: 'Quy định nhiên liệu',
            desc: 'Trả xe nguyên trạng mức nhiên liệu như khi bàn giao.',
          ),
        ],
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _TermRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final iconBg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer.withValues(alpha: 0.5);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12.5,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
