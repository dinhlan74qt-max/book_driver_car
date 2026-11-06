import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class HomeHeroCard extends StatelessWidget {
  final String userName;
  final String subtitle;
  final String searchPlaceholder;
  final VoidCallback onSearchTap;

  const HomeHeroCard({
    super.key,
    required this.userName,
    required this.subtitle,
    required this.searchPlaceholder,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greeting = userName.isNotEmpty ? 'Xin chào, $userName' : 'Xin chào bạn';

    return Container(
      padding: EdgeInsets.all(context.isSmallPhone ? 18 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF06111C),
                  Color(0xFF0B1F33),
                  Color(0xFF13324F),
                ]
              : const [
                  Color(0xFF082236),
                  AppColors.primary,
                  Color(0xFF1B4F72),
                ],
        ),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: isDark ? 0.45 : 0.25),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'CarNow Premium',
                          style: AppTypography.dataLabel.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                greeting,
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  fontSize: context.isSmallPhone ? 22 : 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTypography.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TapScale(
                onTap: onSearchTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          searchPlaceholder,
                          style: AppTypography.body.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ],
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
