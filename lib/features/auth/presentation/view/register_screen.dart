import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/auth/domain/entities/register_request_entity.dart';
import 'package:book_drive_car/features/auth/presentation/bloc/send_otp_bloc.dart';
import 'package:book_drive_car/features/auth/presentation/bloc/send_otp_event.dart';
import 'package:book_drive_car/features/auth/presentation/bloc/send_otp_state.dart';
import 'package:book_drive_car/features/auth/presentation/view/otp_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context) {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      AppToast.show(
        context,
        message: "Vui lòng điền đầy đủ tất cả thông tin",
        type: AppToastType.warning,
      );
      return;
    }
    context.read<SendOtpBloc>().add(
      SendOtpSubmitted(
        RegisterRequestEntity(
          fullname: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          cccd: '',
          address: '',
        ),
      ),
    );
  }

  void _goToOtpScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, __) => OtpScreen(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
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

    return BlocProvider(
      create: (context) => sl<SendOtpBloc>(),
      child: BlocConsumer<SendOtpBloc, SendOtpState>(
        listener: (context, state) {
          if (state is SendOtpSuccess) {
            if (!mounted) return;
            _goToOtpScreen(context);
            try {
              AppToast.show(
                context,
                message: state.message,
                type: AppToastType.success,
              );
            } catch (_) {}
          } else if (state is SendOtpFailure) {
            AppToast.show(
              context,
              message: state.error,
              type: AppToastType.warning,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SendOtpLoading;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    ),
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
                                    ? const [AppColors.darkAccent, AppColors.darkPrimary]
                                    : const [AppColors.accent, AppColors.primary],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: isDark ? AppColors.darkBackground : Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tạo tài khoản mới',
                            style: AppTypography.display.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bắt đầu hành trình thuê xe nhanh chóng và an tâm cùng CarNow.',
                            style: AppTypography.body.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Form Inputs ────────────────────────────────────────────
                    Text(
                      'Họ và tên',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nguyễn Văn A',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          size: 20,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 16),

                    Text(
                      'Số điện thoại',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0901234567',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                      onSubmitted: (_) => _onRegisterPressed(context),
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tạo mật khẩu bảo vệ',
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
                    const SizedBox(height: 28),

                    // ── Submit Button ──────────────────────────────────────────
                    AppButton(
                      text: 'Tiếp tục nhận mã OTP',
                      width: double.infinity,
                      isLoading: isLoading,
                      onPressed: () => _onRegisterPressed(context),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    ),
                    const SizedBox(height: 20),

                    // ── Back to Login ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản? ',
                          style: AppTypography.body.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        TapScale(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Đăng nhập',
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
