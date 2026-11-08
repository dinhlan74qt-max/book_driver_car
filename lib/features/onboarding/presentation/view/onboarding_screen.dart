import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/auth/presentation/view/login_screen.dart';
import 'package:book_drive_car/features/onboarding/data/onboarding_page_data.dart';
import 'package:book_drive_car/features/onboarding/presentation/widget/road_progress_indicator.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;
  double _page = 0;
  int _currentIndex = 0;

  int get _lastIndex => onboardingPages.length - 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController()
      ..addListener(() {
        if (!_controller.hasClients) return;
        final page = _controller.page;
        if (page == null) return;
        setState(() {
          _page = page;
          _currentIndex = page.round().clamp(0, _lastIndex);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page.round() == _lastIndex) {
      await _goToApp(context);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goToApp(BuildContext context) async {
    await sl<UserLocalStorage>().markWelcomeSeen();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = _page.round() == _lastIndex;
    final currentAccent = AppColors.pageAccents[_currentIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Skip
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimaryContainer.withValues(alpha: 0.6)
                          : AppColors.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car_filled_rounded,
                          size: 15,
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'CARNOW',
                          style: AppTypography.dataLabel.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLastPage)
                    TapScale(
                      onTap: () => _goToApp(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        child: Text(
                          'Bỏ qua',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 38),
                ],
              ),
            ),

            // Artwork Illustration Center
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : const Color(0xFF17251F).withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: onboardingPages.length,
                    itemBuilder: (context, index) {
                      return _IllustrationPane(
                        data: onboardingPages[index],
                        accentColor: AppColors.pageAccents[index],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Content & Controls Bottom Sheet
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0817251F),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _TextPane(
                          key: ValueKey(_currentIndex),
                          data: onboardingPages[_currentIndex],
                          accentColor: currentAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RoadProgressIndicator(
                      page: _page,
                      pageCount: onboardingPages.length,
                      accentColors: AppColors.pageAccents,
                      trackColor: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      text: isLastPage ? 'Bắt đầu ngay' : 'Tiếp tục',
                      width: double.infinity,
                      height: 52,
                      trailingIcon: isLastPage
                          ? const Icon(Icons.key_rounded, size: 20)
                          : null,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationPane extends StatelessWidget {
  final OnboardingPageData data;
  final Color accentColor;

  const _IllustrationPane({required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurfaceSecondary : Colors.white,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(data.icon, size: 58, color: accentColor),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSecondary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.statValue,
                    style: AppTypography.dataLabel.copyWith(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.statLabel,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextPane extends StatelessWidget {
  final OnboardingPageData data;
  final Color accentColor;

  const _TextPane({super.key, required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          data.eyebrow,
          style: AppTypography.dataLabel.copyWith(
            color: accentColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.title,
          style: AppTypography.display.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data.description,
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}
