import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CarDetailTermsCard extends StatelessWidget {
  const CarDetailTermsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          _TermRow(
            icon: Icons.badge_outlined,
            title: 'Giấy tờ bắt buộc',
            desc: 'GPLX (hạng B2 trở lên) + CCCD gắn chip đối chiếu khi nhận xe.',
          ),
          Divider(height: 20, color: AppColors.border),
          _TermRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Tài sản thế chấp',
            desc: '15.000.000đ tiền mặt hoặc Xe máy chính chủ kèm cavet xe.',
          ),
          Divider(height: 20, color: AppColors.border),
          _TermRow(
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

  const _TermRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
