import 'dart:ui';

import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/ai_assistant/presentation/view/ai_assistant_screen.dart';
import 'package:book_drive_car/features/home/presentation/view/home/home_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/profile_screen.dart';
import 'package:book_drive_car/features/rental/presentation/view/rental_screen.dart';
import 'package:book_drive_car/features/wallet/presentation/view/wallet_screen.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RentalScreen(),
    AiAssistantScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  final List<_TabItem> _tabs = const [
    _TabItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Khám phá',
    ),
    _TabItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Đơn thuê',
    ),
    _TabItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'Trợ lý AI',
    ),
    _TabItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Ví CarNow',
    ),
    _TabItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Tài khoản',
    ),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _FloatingGlassNavBar(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _FloatingGlassNavBar extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingGlassNavBar({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Palette tokens
    final navSurface = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.94);
    final navBorder = isDark
        ? AppColors.darkBorder.withValues(alpha: 0.75)
        : AppColors.border.withValues(alpha: 0.85);
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final inactiveColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final activePillBg = isDark
        ? AppColors.darkPrimaryContainer.withValues(alpha: 0.75)
        : AppColors.primaryContainer.withValues(alpha: 0.70);
    final activePillBorder = isDark
        ? AppColors.darkPrimary.withValues(alpha: 0.25)
        : AppColors.primary.withValues(alpha: 0.15);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : const Color(0xFF1B4F72).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : const Color(0xFF0F1115).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: navSurface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: navBorder, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(tabs.length, (index) {
                    final tab = tabs[index];
                    final isActive = index == currentIndex;

                    return Expanded(
                      child: TapScale(
                        onTap: () => onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? activePillBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isActive ? activePillBorder : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top Accent Dot on active
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isActive ? 4 : 0,
                                height: isActive ? 4 : 0,
                                margin: EdgeInsets.only(bottom: isActive ? 3 : 0),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AnimatedScale(
                                scale: isActive ? 1.08 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  isActive ? tab.activeIcon : tab.icon,
                                  size: 22,
                                  color: isActive ? activeColor : inactiveColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tab.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                  color: isActive
                                      ? activeColor
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary),
                                  letterSpacing: isActive ? -0.1 : 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
