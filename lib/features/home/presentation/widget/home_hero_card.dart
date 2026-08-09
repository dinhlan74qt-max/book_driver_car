import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';


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
    final greeting = userName.isNotEmpty ? 'Xin chào, $userName' : 'Xin chào!';

    return Container(
      padding: EdgeInsets.all(context.isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF11161F),
            Color(0xFF1A2230),
            Color(0xFF0F1722),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.38),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -12,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.headlightAmber.withValues(alpha: 0.22),
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
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          size: 14,
                          color: AppColors.headlightAmber,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Premium Drive',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                greeting,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: context.isSmallPhone ? 22 : 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              TapScale(
                onTap: onSearchTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.headlightAmber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          searchPlaceholder,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.tune_rounded,
                        color: Colors.white70,
                        size: 20,
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
