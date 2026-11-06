import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class WalletDepositQrScreen extends StatelessWidget {
  final int amount;
  final String qrCodeUrl;
  final String transactionCode;

  const WalletDepositQrScreen({
    super.key,
    required this.amount,
    required this.qrCodeUrl,
    required this.transactionCode,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.decimalPattern('vi_VN');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Thanh toán nạp tiền QR',
          style: AppTypography.titleMedium.copyWith(color: textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quét mã QR để hoàn tất',
                style: AppTypography.display.copyWith(fontSize: 24, color: textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Vui lòng mở ứng dụng ngân hàng hoặc ví điện tử để quét mã và chuyển chính xác số tiền bên dưới.',
                style: AppTypography.body.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 20),

              // ── QR Container ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark ? null : AppColors.shadowSm,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, // QR code scanner requires pure white background
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          qrCodeUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 240,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(primaryColor),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 240,
                              alignment: Alignment.center,
                              child: Text(
                                'Không tải được ảnh mã QR',
                                style: AppTypography.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Số tiền cần chuyển',
                      style: AppTypography.caption.copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${priceFormat.format(amount)}đ',
                      style: AppTypography.priceLarge.copyWith(
                        fontSize: 26,
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Transaction Details ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark ? null : AppColors.shadowSm,
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Mục đích',
                      value: 'Nạp tiền ví CarNow',
                      textColor: textPrimary,
                      captionColor: textSecondary,
                    ),
                    Divider(height: 18, color: borderColor),
                    _InfoRow(
                      label: 'Mã giao dịch',
                      value: transactionCode,
                      textColor: textPrimary,
                      captionColor: textSecondary,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: transactionCode));
                          AppToast.show(
                            context,
                            message: 'Đã sao chép mã giao dịch',
                            type: AppToastType.success,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Note Card ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimaryContainer.withValues(alpha: 0.5)
                      : AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sau khi chuyển khoản thành công, hệ thống sẽ tự động cập nhật số dư ví trong 1 - 3 phút. Kéo để tải lại ví để kiểm tra.',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                text: 'Đã hoàn tất thanh toán',
                width: double.infinity,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final Color? textColor;
  final Color? captionColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.textColor,
    this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(fontSize: 13, color: captionColor),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: textColor ?? AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
