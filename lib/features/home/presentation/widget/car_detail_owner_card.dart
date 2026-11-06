import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CarDetailOwnerCard extends StatelessWidget {
  const CarDetailOwnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

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
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: primaryColor,
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Chủ xe Uy tín',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded, size: 18, color: isDark ? AppColors.darkAccent : AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• Tỷ lệ phản hồi 100%',
                          style: TextStyle(fontSize: 12, color: textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: borderColor),
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
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
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
                    backgroundColor: primaryColor.withValues(alpha: 0.12),
                    foregroundColor: primaryColor,
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
