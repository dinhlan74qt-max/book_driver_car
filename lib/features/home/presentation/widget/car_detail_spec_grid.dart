import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';

class SpecItem {
  final IconData icon;
  final String label;
  final String value;

  const SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class CarDetailSpecGrid extends StatelessWidget {
  final List<SpecItem> specs;

  const CarDetailSpecGrid({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    final columnCount = context.isTablet ? 4 : (context.isSmallPhone ? 1 : 2);
    final aspectRatio = context.isTablet ? 3.2 : 2.8;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: specs.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (_, index) {
          final item = specs[index];
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
