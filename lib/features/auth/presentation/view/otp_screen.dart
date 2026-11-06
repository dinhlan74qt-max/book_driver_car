import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/auth/domain/usecases/verify_otp.dart';
import 'package:book_drive_car/features/auth/presentation/view/login_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String phone;

  const OtpScreen({super.key, required this.email, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  final VerifyOtp _verifyOtp = sl<VerifyOtp>();
  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  bool _isVerifying = false;

  String get _otpValue => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_otpValue.length == _otpLength) {
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_otpValue.length < _otpLength || _isVerifying) return;

    setState(() => _isVerifying = true);

    try {
      final message = await _verifyOtp(
        email: widget.email,
        otpCode: _otpValue,
      );

      if (!mounted) return;

      AppToast.show(context, message: message, type: AppToastType.success);

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, animation, __) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;

      AppToast.show(
        context,
        message: e.toString().replaceFirst("Exception: ", ""),
        type: AppToastType.warning,
      );

      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                              ? const [AppColors.darkPrimary, AppColors.darkAccent]
                              : const [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.mark_email_read_rounded,
                        color: isDark ? AppColors.darkBackground : Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Xác thực OTP',
                      style: AppTypography.display.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mã xác nhận gồm 6 chữ số đã được gửi tới email của bạn.',
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkPrimaryContainer.withValues(alpha: 0.5)
                            : AppColors.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 18,
                            color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleSmall.copyWith(
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Nhập 6 chữ số mã xác nhận',
                style: AppTypography.label.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // ── Pin Input Boxes ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return _OtpBox(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (value) => _onChanged(index, value),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // ── Submit Button ──────────────────────────────────────────
              AppButton(
                text: 'Xác nhận OTP',
                width: double.infinity,
                isLoading: _isVerifying,
                onPressed: _verify,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
              ),
              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: _isVerifying
                      ? null
                      : () {
                          AppToast.show(
                            context,
                            message: 'Đã gửi lại mã OTP vào hộp thư của bạn',
                            type: AppToastType.info,
                          );
                        },
                  child: Text(
                    'Chưa nhận được mã? Gửi lại',
                    style: AppTypography.label.copyWith(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = widget.focusNode.hasFocus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused
              ? primaryColor
              : (widget.controller.text.isNotEmpty
                  ? primaryColor.withValues(alpha: 0.5)
                  : borderColor),
          width: _isFocused ? 2.0 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTypography.metricLarge.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
