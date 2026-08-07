import 'package:book_drive_car/core/theme/app_colors.dart';
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            child: const Text('Xoá bộ lọc'),
          ),
        ],
      ),
    );
  }
}
