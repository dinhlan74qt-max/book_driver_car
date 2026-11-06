import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/auth/presentation/bloc/login_bloc.dart';
import 'package:book_drive_car/features/auth/presentation/bloc/login_event.dart';
import 'package:book_drive_car/features/auth/presentation/bloc/login_state.dart';
import 'package:book_drive_car/features/auth/presentation/view/register_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/bottom_navigation_bar.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập đầy đủ email và mật khẩu',
        type: AppToastType.warning,
      );
      return;
    }
    context.read<LoginBloc>().add(
      LoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  void _goToHomeScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => const MainNavigation(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
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
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<LoginBloc>(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            if (!mounted) return;
            _goToHomeScreen(context);
            try {
              AppToast.show(
                context,
                message: "Đăng nhập thành công!",
                type: AppToastType.success,
              );
            } catch (_) {}
          } else if (state is LoginFailure) {
            AppToast.show(
              context,
              message: state.error,
              type: AppToastType.warning,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Navigator.of(context).canPop())
                      TapScale(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF17251F).withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 12),
                    const SizedBox(height: 24),

                    // ── Brand Header Card (Ivory & Forest Green) ───────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.22) : const Color(0xFF17251F).withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? const [AppColors.darkPrimary, AppColors.darkAccent]
                                    : const [AppColors.primary, AppColors.accent],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.key_rounded,
                              color: isDark ? AppColors.darkBackground : Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chào mừng trở lại',
                            style: AppTypography.display.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đăng nhập để tiếp tục quản lý hành trình và chiếc xe của bạn.',
                            style: AppTypography.body.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Form Inputs ────────────────────────────────────────────
                    Text(
                      'Địa chỉ Email',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'name@example.com',
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          size: 20,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Mật khẩu',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(context),
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu của bạn',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          AppToast.show(
                            context,
                            message: 'Tính năng khôi phục mật khẩu đang được hỗ trợ qua email hỗ trợ!',
                            type: AppToastType.info,
                          );
                        },
                        child: Text(
                          'Quên mật khẩu?',
                          style: AppTypography.label.copyWith(
                            color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Submit Button ──────────────────────────────────────────
                    AppButton(
                      text: 'Đăng nhập',
                      width: double.infinity,
                      isLoading: isLoading,
                      onPressed: () => _login(context),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    ),
                    const SizedBox(height: 24),

                    // ── Register Navigation ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: AppTypography.body.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        TapScale(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Đăng ký ngay',
                            style: AppTypography.label.copyWith(
                              color: isDark ? AppColors.darkAccent : AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
