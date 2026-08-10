import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OwnerBookingDetailScreen extends StatefulWidget {
  final OwnerBookingEntity booking;

  const OwnerBookingDetailScreen({super.key, required this.booking});

  @override
  State<OwnerBookingDetailScreen> createState() => _OwnerBookingDetailScreenState();
}

class _OwnerBookingDetailScreenState extends State<OwnerBookingDetailScreen> {
  late OwnerBookingEntity _currentBooking;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  String _formatPrice(num price) {
    return NumberFormat.decimalPattern('vi_VN').format(price);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('HH:mm - dd/MM/yyyy').format(dt);
  }

  Future<void> _handleApprove() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận duyệt đơn'),
        content: Text('Bạn có đồng ý cho khách hàng ${_currentBooking.renterName} thuê xe ${_currentBooking.vehicleName} không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Đồng ý duyệt'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    final success = await context.read<OwnerBookingCubit>().approveBooking(_currentBooking.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      setState(() {
        _currentBooking = _currentBooking.copyWith(status: BookingStatus.approved);
      });
      AppToast.show(
        context,
        message: 'Đã duyệt đơn ${_currentBooking.bookingCode} thành công',
        type: AppToastType.success,
      );
    } else {
      AppToast.show(
        context,
        message: 'Không thể duyệt đơn. Vui lòng thử lại!',
        type: AppToastType.error,
      );
    }
  }

  Future<void> _handleReject() async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối đơn đặt xe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối (tùy chọn):'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Xe đang bảo dưỡng, bận lịch...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Từ chối đơn'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    final success = await context.read<OwnerBookingCubit>().rejectBooking(
          _currentBooking.id,
          reason: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : null,
        );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      setState(() {
        _currentBooking = _currentBooking.copyWith(
          status: BookingStatus.rejected,
          note: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : _currentBooking.note,
        );
      });
      AppToast.show(
        context,
        message: 'Đã từ chối đơn ${_currentBooking.bookingCode} thành công',
        type: AppToastType.success,
      );
      return;
    }

    AppToast.show(
      context,
      message: 'Không thể từ chối đơn. Vui lòng thử lại!',
      type: AppToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentBooking.status;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn: ${_currentBooking.bookingCode}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Thẻ Trạng Thái Đơn ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: status.color.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: status.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(status.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trạng thái: ${status.label}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: status.color,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _getStatusDescription(status),
                          style: TextStyle(fontSize: 12.5, color: Colors.black.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 2. Thông Tin Xe Thuê ──────────────────────────────────────────
            const _SectionHeader(title: 'Thông tin xe cho thuê', icon: Icons.directions_car_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: _currentBooking.vehicleImage.isNotEmpty
                          ? Image.network(
                              _currentBooking.vehicleImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary),
                              ),
                            )
                          : Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentBooking.vehicleName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _currentBooking.licensePlate,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF7D5A00)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đơn giá: ${_formatPrice(_currentBooking.pricePerDay)} đ/ngày',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 3. Thông Tin Khách Thuê ───────────────────────────────────────
            const _SectionHeader(title: 'Thông tin người thuê', icon: Icons.person_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentBooking.renterName,
                              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentBooking.renterPhone,
                              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đang mở ứng dụng tin nhắn với ${_currentBooking.renterPhone}...')),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          label: const Text('Nhắn tin'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đang gọi cho khách: ${_currentBooking.renterPhone}...')),
                            );
                          },
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                          label: const Text('Gọi điện'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 4. Thời Gian & Lịch Trình ─────────────────────────────────────
            const _SectionHeader(title: 'Lịch trình thuê xe', icon: Icons.calendar_month_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoRowItem(
                    label: 'Thời gian nhận xe',
                    value: _formatDate(_currentBooking.startDate),
                    icon: Icons.login_rounded,
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _InfoRowItem(
                    label: 'Thời gian trả xe',
                    value: _formatDate(_currentBooking.endDate),
                    icon: Icons.logout_rounded,
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _InfoRowItem(
                    label: 'Tổng thời gian thuê',
                    value: '${_currentBooking.totalDays} ngày',
                    icon: Icons.timer_outlined,
                  ),
                  if (_currentBooking.note?.isNotEmpty == true) ...[
                    const Divider(height: 20, color: AppColors.border),
                    _InfoRowItem(
                      label: 'Ghi chú của khách',
                      value: _currentBooking.note!,
                      icon: Icons.notes_rounded,
                      isMultiline: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 5. Chi Tiết Doanh Thu & Thanh Toán ────────────────────────────
            const _SectionHeader(title: 'Chi tiết thanh toán', icon: Icons.receipt_long_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _PriceRow(
                    label: 'Đơn giá thuê (${_currentBooking.totalDays} ngày)',
                    value: '${_formatPrice(_currentBooking.pricePerDay * _currentBooking.totalDays)} đ',
                  ),
                  const SizedBox(height: 10),
                  const _PriceRow(label: 'Phí dịch vụ nền tảng', value: '0 đ'),
                  const SizedBox(height: 10),
                  const _PriceRow(label: 'Bảo hiểm chuyến đi', value: 'Miễn phí'),
                  const Divider(height: 24, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thực nhận',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${_formatPrice(_currentBooking.totalPrice)} đ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── BOTTOM ACTION BAR (DUYỆT / TỪ CHỐI CHO ĐƠN PENDING) ─────────────────
      bottomNavigationBar: status == BookingStatus.pending
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : _handleReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Từ chối',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _handleApprove,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                      label: Text(
                        _isProcessing ? 'Đang xử lý...' : 'Duyệt đơn ngay',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  String _getStatusDescription(BookingStatus st) {
    switch (st) {
      case BookingStatus.pending:
        return 'Khách hàng đang chờ bạn duyệt đơn để chuẩn bị nhận xe.';
      case BookingStatus.approved:
        return 'Đơn đã được duyệt. Hãy chuẩn bị bàn giao xe đúng giờ.';
      case BookingStatus.renting:
        return 'Khách hàng đang nhận xe và trong thời gian thuê.';
      case BookingStatus.completed:
        return 'Đơn thuê đã hoàn tất, xe đã được bàn giao lại an toàn.';
      case BookingStatus.rejected:
        return 'Đơn đặt thuê này đã bị từ chối.';
      case BookingStatus.cancelled:
        return 'Khách hàng đã hủy đơn thuê này.';
    }
  }
}

// ── Widget Section Header ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ── Widget Info Row Item ──────────────────────────────────────────────────────

class _InfoRowItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isMultiline;

  const _InfoRowItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Flexible(
          flex: isMultiline ? 2 : 1,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ── Widget Price Row ──────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
