import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CarDetailOwnerCard extends StatelessWidget {
  const CarDetailOwnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Chủ xe Uy tín',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded, size: 18, color: Colors.blue.shade600),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        SizedBox(width: 3),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '• Tỷ lệ phản hồi 100%',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang kết nối tin nhắn với chủ xe...')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Nhắn tin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang gọi điện cho chủ xe...')),
                    );
                  },
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                  label: const Text('Gọi điện'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
