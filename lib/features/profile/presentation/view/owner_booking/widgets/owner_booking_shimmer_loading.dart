import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OwnerBookingShimmerLoading extends StatelessWidget {
  const OwnerBookingShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, _) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 100, height: 16, color: Colors.black12),
                Container(width: 70, height: 16, color: Colors.black12),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(width: 60, height: 60, color: Colors.black12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 14, color: Colors.black12),
                      const SizedBox(height: 8),
                      Container(width: 120, height: 12, color: Colors.black12),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
