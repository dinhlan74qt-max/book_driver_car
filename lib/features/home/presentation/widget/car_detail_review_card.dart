import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CarDetailReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String comment;

  const CarDetailReviewCard({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      name[0],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(fontSize: 11.5, color: textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: TextStyle(
              fontSize: 13.5,
              color: textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
