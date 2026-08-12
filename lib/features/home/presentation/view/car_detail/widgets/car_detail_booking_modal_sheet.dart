import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/data/datasources/booking_remote_data_source.dart';
import 'package:book_drive_car/features/home/domain/entities/booking_request_entity.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/booking_contract_flow.dart';
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
  State<CarDetailBookingModalSheet> createState() => _CarDetailBookingModalSheetState();
}

class _CarDetailBookingModalSheetState extends State<CarDetailBookingModalSheet> {
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
      final bookingRemoteDataSource = sl<BookingRemoteDataSource>();
      final verifiedUser = await bookingRemoteDataSource.checkVerified();

      debugPrint(
        '[BookingSubmit] vehicleId=$vehicleId start=${widget.selectedDateRange.start.toIso8601String()} end=${widget.selectedDateRange.end.toIso8601String()}',
      );

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
      AppToast.show(
        null,
        message: 'Đặt xe thành công! Vui lòng vào "Đơn thuê" để kiểm tra thông tin.',
        type: AppToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[BookingSubmit] error=$errorMessage');
      AppToast.show(
        context,
        message: errorMessage,
        type: AppToastType.error,
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Xác nhận đặt xe ${widget.car.name}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thời gian thuê:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(
                      '${_formatDate(widget.selectedDateRange.start)} - ${_formatDate(widget.selectedDateRange.end)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng số ngày:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(
                      '${widget.rentalDays} ngày',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Đơn giá:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(
                      '${widget.formatPrice(widget.car.pricePerDay)}/ngày',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ],
                ),
                const Divider(height: 18, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng thanh toán:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(
                      widget.formatPrice(widget.totalPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
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
            decoration: InputDecoration(
              hintText: 'Ghi chú cho chủ xe (tùy chọn)...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Gửi yêu cầu thuê xe', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
