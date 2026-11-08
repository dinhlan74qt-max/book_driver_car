import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/profile/data/datasources/user_security_remote_data_source.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi tức thì từ cả 3 trường để cập nhật trạng thái các quy tắc ngay lập tức
    _currentPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_onFieldChanged);
    _newPasswordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    if (_isLoading) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập mật khẩu hiện tại',
        type: AppToastType.warning,
      );
      return;
    }

    if (newPassword.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập mật khẩu mới',
        type: AppToastType.warning,
      );
      return;
    }

    if (newPassword.length < 6) {
      AppToast.show(
        context,
        message: 'Mật khẩu mới phải có ít nhất 6 ký tự',
        type: AppToastType.warning,
      );
      return;
    }

    if (newPassword == currentPassword) {
      AppToast.show(
        context,
        message: 'Mật khẩu mới không được trùng với mật khẩu hiện tại',
        type: AppToastType.warning,
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng xác nhận lại mật khẩu mới',
        type: AppToastType.warning,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      AppToast.show(
        context,
        message: 'Mật khẩu xác nhận không trùng khớp',
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dataSource = sl.isRegistered<UserSecurityRemoteDataSource>()
          ? sl<UserSecurityRemoteDataSource>()
          : UserSecurityRemoteDataSourceImpl(
              sl.isRegistered<Dio>() ? sl<Dio>() : Dio(),
              sl.isRegistered<UserLocalStorage>()
                  ? sl<UserLocalStorage>()
                  : UserLocalStorage(),
            );
      final message = await dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      AppToast.show(
        context,
        message: message,
        type: AppToastType.success,
      );

      // Đổi mật khẩu thành công -> quay lại màn hình trước
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppToast.show(
        context,
        message: msg,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: (_) => _onFieldChanged(),
            style: AppTypography.bodyMedium.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.bodySmall.copyWith(color: textSecondary),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: primaryColor,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: textSecondary,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem({
    required bool isValid,
    required String text,
    required Color textSecondary,
  }) {
    final activeColor = AppColors.success;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isValid
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              key: ValueKey<bool>(isValid),
              size: 16,
              color: isValid ? activeColor : textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.caption.copyWith(
                color: isValid ? activeColor : textSecondary,
                fontWeight: isValid ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final surfaceSecondary =
        isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF8FAFC);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    final hasMinLength = newPass.length >= 6;
    final hasMatch = newPass.isNotEmpty && newPass == confirmPass;
    final isDiffCurrent = newPass.isNotEmpty &&
        _currentPasswordController.text.isNotEmpty &&
        newPass != _currentPasswordController.text;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Đổi mật khẩu',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cardColor,
        foregroundColor: textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner thông tin bảo mật
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.security_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bảo vệ tài khoản',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mật khẩu mới phải có ít nhất 6 ký tự. Hãy đặt mật khẩu an toàn và không chia sẻ cho người khác.',
                              style: AppTypography.bodySmall.copyWith(
                                color: textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form nhập mật khẩu
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                    boxShadow: AppColors.shadowSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordField(
                        label: 'Mật khẩu hiện tại',
                        hintText: 'Nhập mật khẩu hiện tại...',
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        onToggleObscure: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                        surfaceColor: surfaceSecondary,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        label: 'Mật khẩu mới',
                        hintText: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)...',
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        onToggleObscure: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        surfaceColor: surfaceSecondary,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        label: 'Xác nhận mật khẩu mới',
                        hintText: 'Nhập lại mật khẩu mới...',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        onToggleObscure: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        surfaceColor: surfaceSecondary,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 20),

                      // Quy tắc mật khẩu
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surfaceSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quy tắc mật khẩu:',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRequirementItem(
                              isValid: hasMinLength,
                              text: 'Độ dài tối thiểu từ 6 ký tự',
                              textSecondary: textSecondary,
                            ),
                            _buildRequirementItem(
                              isValid: isDiffCurrent,
                              text: 'Khác với mật khẩu hiện tại',
                              textSecondary: textSecondary,
                            ),
                            _buildRequirementItem(
                              isValid: hasMatch,
                              text: 'Mật khẩu xác nhận trùng khớp',
                              textSecondary: textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Nút Đổi mật khẩu
                AppButton(
                  text: 'Đổi mật khẩu',
                  icon: const Icon(Icons.lock_reset_rounded),
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _submitChangePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
