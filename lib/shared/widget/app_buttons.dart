import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outline, danger, ghost }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final dynamic icon;
  final dynamic trailingIcon;
  final AppButtonVariant variant;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 50,
    this.borderRadius,
  });

  Widget? _resolveIcon(dynamic ic, Color fg) {
    if (ic == null) return null;
    if (ic is IconData) return Icon(ic, size: 18, color: fg);
    if (ic is Widget) return ic;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final isInteractive = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        if (isDark) {
          bg = isInteractive
              ? AppColors.darkPrimary
              : AppColors.darkPrimary.withValues(alpha: 0.5);
          fg = AppColors.darkBackground;
        } else {
          bg = isInteractive
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.6);
          fg = Colors.white;
        }
        break;
      case AppButtonVariant.secondary:
        if (isDark) {
          bg = isInteractive
              ? AppColors.darkAccent
              : AppColors.darkAccent.withValues(alpha: 0.5);
          fg = AppColors.darkBackground;
        } else {
          bg = isInteractive
              ? AppColors.accent
              : AppColors.accent.withValues(alpha: 0.6);
          fg = Colors.white;
        }
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = isInteractive
            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
            : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
        border = Border.all(
          color: isInteractive
              ? (isDark ? AppColors.darkBorder : AppColors.border)
              : (isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.5)
                    : AppColors.borderSubtle),
          width: 1.2,
        );
        break;
      case AppButtonVariant.danger:
        if (isDark) {
          bg = isInteractive
              ? AppColors.darkDanger
              : AppColors.darkDanger.withValues(alpha: 0.5);
          fg = Colors.white;
        } else {
          bg = isInteractive
              ? AppColors.danger
              : AppColors.danger.withValues(alpha: 0.6);
          fg = Colors.white;
        }
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isInteractive
            ? (isDark ? AppColors.darkTextPrimary : AppColors.textSecondary)
            : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
        break;
    }

    final leading = _resolveIcon(icon, fg);
    final trailing = _resolveIcon(trailingIcon, fg);

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (leading != null) ...[leading, const SizedBox(width: 8)],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.button.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ],
    );

    return TapScale(
      onTap: isInteractive ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: border,
          boxShadow:
              (isInteractive &&
                  (variant == AppButtonVariant.primary ||
                      variant == AppButtonVariant.secondary))
              ? [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: content,
      ),
    );
  }
}
