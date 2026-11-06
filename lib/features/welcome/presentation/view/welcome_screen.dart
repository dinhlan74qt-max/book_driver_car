import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/auth/presentation/view/login_screen.dart';
import 'package:book_drive_car/features/auth/presentation/view/register_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  PageRouteBuilder<void> _routeTo(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(_routeTo(page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand Bar
              StaggeredFadeIn(
                index: 0,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [AppColors.darkPrimary, AppColors.darkAccent]
                              : const [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        color: isDark ? AppColors.darkBackground : Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CarNow',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Nền tảng thuê xe tự lái cao cấp',
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Visual Hero Artwork Card (Forest Green & Ivory)
              StaggeredFadeIn(
                index: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
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
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        bottom: -30,
                        child: Container(
                          width: 160,
                          height: 160,
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
                                const Icon(Icons.bolt_rounded, size: 14, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Text(
                                  'Trải nghiệm di chuyển thế hệ mới',
                                  style: AppTypography.dataLabel.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Khởi đầu hành trình hoàn hảo',
                            style: AppTypography.display.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hàng trăm mẫu xe đời mới sẵn sàng đón bạn ở khắp các tỉnh thành với thủ tục số hóa 100%.',
                            style: AppTypography.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Feature Badges Row
              StaggeredFadeIn(
                index: 2,
                child: const Row(
                  children: [
                    _FeaturePill(icon: Icons.security_rounded, label: 'Bảo hiểm toàn diện'),
                    SizedBox(width: 8),
                    _FeaturePill(icon: Icons.timer_outlined, label: 'Nhận xe 60 giây'),
                    SizedBox(width: 8),
                    _FeaturePill(icon: Icons.verified_user_rounded, label: 'Xe chính chủ'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              StaggeredFadeIn(
                index: 3,
                child: Column(
                  children: [
                    AppButton(
                      text: 'Đăng nhập vào tài khoản',
                      width: double.infinity,
                      height: 52,
                      icon: const Icon(Icons.login_rounded, size: 20),
                      onPressed: () => _open(context, const LoginScreen()),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Tạo tài khoản mới',
                      width: double.infinity,
                      height: 52,
                      variant: AppButtonVariant.outline,
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                      onPressed: () => _open(context, const RegisterScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0xFF17251F).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
