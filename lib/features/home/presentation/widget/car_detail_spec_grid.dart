import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.getSurface(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final primaryColor = AppColors.getPrimary(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final iconBg = AppColors.getPrimaryContainer(isDark);

    final itemsPerRow = context.isTablet ? 4 : 2;
    final List<Widget> rowWidgets = [];

    for (int i = 0; i < specs.length; i += itemsPerRow) {
      if (rowWidgets.isNotEmpty) {
        rowWidgets.add(const SizedBox(height: 12));
      }
      final rowChildren = <Widget>[];
      for (int j = 0; j < itemsPerRow; j++) {
        if (j > 0) rowChildren.add(const SizedBox(width: 12));
        final index = i + j;
        if (index < specs.length) {
          rowChildren.add(
            Expanded(
              child: _buildSpecCard(
                specs[index],
                isDark: isDark,
                borderColor: borderColor,
                primaryColor: primaryColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                iconBg: iconBg,
              ),
            ),
          );
        } else {
          rowChildren.add(const Spacer());
        }
      }
      rowWidgets.add(Row(children: rowChildren));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rowWidgets),
    );
  }

  Widget _buildSpecCard(
    SpecItem item, {
    required bool isDark,
    required Color borderColor,
    required Color primaryColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceSubtle(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 20, color: primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
