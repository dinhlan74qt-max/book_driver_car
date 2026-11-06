import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

enum AppCardVariant { standard, elevated, outlined, subtle, kpi }

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final double borderRadius;
  final bool hasBorder;
  final bool hasShadow;
  final AppCardVariant variant;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.color,
    this.borderRadius = 20,
    this.hasBorder = true,
    this.hasShadow = true,
    this.variant = AppCardVariant.standard,
  });

  const AppCard.outlined({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.color,
    this.borderRadius = 20,
  })  : hasBorder = true,
        hasShadow = false,
        variant = AppCardVariant.outlined;

  const AppCard.subtle({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.color,
    this.borderRadius = 20,
  })  : hasBorder = false,
        hasShadow = false,
        variant = AppCardVariant.subtle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Border? border;
    List<BoxShadow>? shadows;

    switch (variant) {
      case AppCardVariant.standard:
      case AppCardVariant.elevated:
        bg = color ?? (isDark ? AppColors.darkSurface : AppColors.surface);
        border = hasBorder
            ? Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1,
              )
            : null;
        shadows = hasShadow
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.22)
                      : const Color(0xFF17251F).withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null;
        break;
      case AppCardVariant.outlined:
        bg = color ?? (isDark ? AppColors.darkSurface : AppColors.surface);
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.2,
        );
        shadows = null;
        break;
      case AppCardVariant.subtle:
        bg = color ?? (isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary);
        border = null;
        shadows = null;
        break;
      case AppCardVariant.kpi:
        bg = color ?? (isDark ? AppColors.darkSurface : AppColors.surface);
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1,
        );
        shadows = [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFF17251F).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ];
        break;
    }

    final cardContent = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return TapScale(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Thẻ KPI / Thống kê chuẩn mực
class AppKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const AppKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary);

    return AppCard(
      variant: AppCardVariant.kpi,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.metricLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
