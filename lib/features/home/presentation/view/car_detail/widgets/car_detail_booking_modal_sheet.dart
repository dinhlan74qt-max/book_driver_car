import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/domain/repositories/booking_repository.dart';
import 'package:book_drive_car/features/home/domain/entities/booking_request_entity.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/booking_contract_flow.dart';
import 'package:book_drive_car/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:book_drive_car/features/wallet/presentation/view/wallet_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarDetailBookingModalSheet extends StatefulWidget {
  final CarEntity car;
  final DateTimeRange selectedDateRange;
  final int rentalDays;
  final int totalPrice;
  final String Function(num) formatPrice;

  const CarDetailBookingModalSheet({
    super.key,
    required this.car,
    required this.selectedDateRange,
    required this.rentalDays,
    required this.totalPrice,
    required this.formatPrice,
  });

  static Future<void> show({
    required BuildContext context,
    required CarEntity car,
    required DateTimeRange selectedDateRange,
    required int rentalDays,
    required int totalPrice,
    required String Function(num) formatPrice,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CarDetailBookingModalSheet(
        car: car,
        selectedDateRange: selectedDateRange,
        rentalDays: rentalDays,
        totalPrice: totalPrice,
        formatPrice: formatPrice,
      ),
    );
  }

  @override
  State<CarDetailBookingModalSheet> createState() =>
      _CarDetailBookingModalSheetState();
}

class _CarDetailBookingModalSheetState
    extends State<CarDetailBookingModalSheet> {
  bool _isSubmitting = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;

    final vehicleId = int.tryParse(widget.car.id);
    if (vehicleId == null) {
      AppToast.show(
        null,
        message: 'Không lấy được mã xe để gửi booking lên server.',
        type: AppToastType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bookingRepository = sl<BookingRepository>();
      final verifiedUser = await bookingRepository.checkVerified();

      // Kiểm tra số dư ví trước khi chuyển sang bước ký hợp đồng
      final walletRepository = sl<WalletRepository>();
      final wallet = await walletRepository.getMyWallet();

      if (wallet.balance < widget.totalPrice) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        await _showInsufficientBalanceSheet(
          currentBalance: wallet.balance,
          requiredAmount: widget.totalPrice,
        );
        return;
      }

      debugPrint(
        '[BookingSubmit] vehicleId=$vehicleId start=${widget.selectedDateRange.start.toIso8601String()} end=${widget.selectedDateRange.end.toIso8601String()}',
      );

      if (!mounted) return;

      final bookingResult = await Navigator.of(context).push<Object?>(
        MaterialPageRoute(
          builder: (_) => BookingContractScreen(
            car: widget.car,
            request: BookingRequestEntity(
              vehicleId: vehicleId,
              startDate: widget.selectedDateRange.start,
              endDate: widget.selectedDateRange.end,
              note: _noteController.text.trim(),
            ),
            renter: verifiedUser,
          ),
        ),
      );

      if (bookingResult == null) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      if (bookingResult == 'timeout') {
        AppToast.show(
          null,
          message:
              'Dữ liệu đã được gửi đi. Nếu chưa hiển thị, vui lòng kéo để tải lại hoặc nhập lại sau.',
          type: AppToastType.success,
        );
      } else {
        AppToast.show(
          null,
          message:
              'Đặt xe thành công! Vui lòng vào "Đơn thuê" để kiểm tra thông tin.',
          type: AppToastType.success,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[BookingSubmit] error=$errorMessage');
      AppToast.show(context, message: errorMessage, type: AppToastType.error);
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showInsufficientBalanceSheet({
    required int currentBalance,
    required int requiredAmount,
  }) async {
    final missingAmount = requiredAmount - currentBalance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final bgColor = isDark
        ? AppColors.darkSurfaceSecondary
        : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.amber,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Số dư ví không đủ',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vui lòng nạp thêm tiền để tiếp tục đặt xe',
                          style: AppTypography.bodySmall.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số dư ví hiện tại:',
                          style: AppTypography.bodySmall.copyWith(
                            color: textSecondary,
                          ),
                        ),
                        Text(
                          widget.formatPrice(currentBalance),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng tiền thuê xe:',
                          style: AppTypography.bodySmall.copyWith(
                            color: textSecondary,
                          ),
                        ),
                        Text(
                          widget.formatPrice(requiredAmount),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 20, color: borderColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cần nạp thêm:',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          widget.formatPrice(missingAmount),
                          style: AppTypography.priceLarge.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: borderColor),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Để sau',
                        style: AppTypography.labelLarge.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: 'Nạp tiền ngay',
                      icon: const Icon(Icons.add_card_rounded, size: 18),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WalletScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final bgColor = isDark
        ? AppColors.darkSurfaceSecondary
        : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Xác nhận đặt ${widget.car.name}',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thời gian thuê:',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '${_formatDate(widget.selectedDateRange.start)} - ${_formatDate(widget.selectedDateRange.end)}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng số ngày:',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '${widget.rentalDays} ngày',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đơn giá niêm yết:',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '${widget.formatPrice(widget.car.pricePerDay)}/ngày',
                      style: AppTypography.priceMedium.copyWith(
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Divider(height: 20, color: borderColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng thanh toán:',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      widget.formatPrice(widget.totalPrice),
                      style: AppTypography.priceLarge.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteController,
            style: TextStyle(color: textPrimary),
            decoration: InputDecoration(
              hintText:
                  'Ghi chú cho chủ xe (thời gian nhận xe, địa chỉ cụ thể...)...',
              hintStyle: AppTypography.bodySmall.copyWith(color: textMuted),
              filled: true,
              fillColor: bgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryColor, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 18),
          AppButton(
            text: 'Tiến hành ký hợp đồng & Đặt xe',
            width: double.infinity,
            isLoading: _isSubmitting,
            onPressed: _submitBooking,
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
