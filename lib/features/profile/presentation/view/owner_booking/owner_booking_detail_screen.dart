import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking_contract_approval_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerBookingDetailScreen extends StatefulWidget {
  final OwnerBookingEntity booking;

  const OwnerBookingDetailScreen({super.key, required this.booking});

  @override
  State<OwnerBookingDetailScreen> createState() =>
      _OwnerBookingDetailScreenState();
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

  Future<void> _callRenterPhone() async {
    final phone = _currentBooking.renterPhone.trim();
    if (phone.isEmpty) {
      AppToast.show(
        context,
        message: 'Không có số điện thoại của khách để gọi',
        type: AppToastType.warning,
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      AppToast.show(
        context,
        message: 'Không thể mở ứng dụng gọi điện',
        type: AppToastType.error,
      );
    }
  }

  Future<void> _handleApprove() async {
    final cubit = context.read<OwnerBookingCubit>();
    final approved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: OwnerBookingContractApprovalScreen(booking: _currentBooking),
        ),
      ),
    );

    if (!mounted) return;
    if (approved == true) {
      setState(() {
        _currentBooking = _currentBooking.copyWith(
          status: BookingStatus.approved,
        );
      });
      AppToast.show(
        context,
        message: 'Đã duyệt đơn ${_currentBooking.bookingCode} thành công',
        type: AppToastType.success,
      );
      return;
    }

    AppToast.show(
      context,
      message: 'Chưa duyệt được đơn. Vui lòng kiểm tra lại file hợp đồng.',
      type: AppToastType.warning,
    );
  }

  Future<void> _handleReject() async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Từ chối đơn đặt xe', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vui lòng nhập lý do từ chối (tùy chọn):', style: AppTypography.body),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Xe đang bảo dưỡng, bận lịch...',
                hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Từ chối đơn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    final success = await context.read<OwnerBookingCubit>().rejectBooking(
      _currentBooking.id,
      reason: reasonController.text.trim().isNotEmpty
          ? reasonController.text.trim()
          : null,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      setState(() {
        _currentBooking = _currentBooking.copyWith(
          status: BookingStatus.rejected,
          note: reasonController.text.trim().isNotEmpty
              ? reasonController.text.trim()
              : _currentBooking.note,
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

  bool get _canMarkReceived {
    final today = DateUtils.dateOnly(DateTime.now());
    final startDay = DateUtils.dateOnly(_currentBooking.startDate);
    return !today.isBefore(startDay);
  }

  bool get _canMarkReturned {
    final today = DateUtils.dateOnly(DateTime.now());
    final startDay = DateUtils.dateOnly(_currentBooking.startDate);
    return !today.isBefore(startDay);
  }

  Future<void> _handleMarkReceived() async {
    if (!_canMarkReceived) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận khách đã nhận xe', style: AppTypography.titleMedium),
        content: Text(
          'Bạn muốn chuyển đơn ${_currentBooking.bookingCode} sang trạng thái khách đã nhận xe không?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    final success = await context
        .read<OwnerBookingCubit>()
        .markCustomerReceived(_currentBooking.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      setState(() {
        _currentBooking = _currentBooking.copyWith(
          status: BookingStatus.renting,
        );
      });
      AppToast.show(
        context,
        message:
            'Đã cập nhật khách đã nhận xe cho đơn ${_currentBooking.bookingCode}',
        type: AppToastType.success,
      );
      return;
    }

    AppToast.show(
      context,
      message: 'Không thể cập nhật trạng thái nhận xe. Vui lòng thử lại!',
      type: AppToastType.error,
    );
  }

  Future<void> _handleMarkReturned() async {
    if (!_canMarkReturned) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận khách đã trả xe', style: AppTypography.titleMedium),
        content: Text(
          'Bạn muốn chuyển đơn ${_currentBooking.bookingCode} sang trạng thái hoàn thành không?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    final success = await context
        .read<OwnerBookingCubit>()
        .markCustomerReturned(_currentBooking.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      setState(() {
        _currentBooking = _currentBooking.copyWith(
          status: BookingStatus.completed,
        );
      });
      AppToast.show(
        context,
        message:
            'Đã cập nhật khách đã trả xe cho đơn ${_currentBooking.bookingCode}',
        type: AppToastType.success,
      );
      return;
    }

    AppToast.show(
      context,
      message: 'Không thể cập nhật trạng thái trả xe. Vui lòng thử lại!',
      type: AppToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentBooking.status;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn: ${_currentBooking.bookingCode}',
          style: AppTypography.titleMedium.copyWith(color: textPrimary),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Thẻ Trạng Thái Đơn ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: status.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
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
                          style: AppTypography.titleMedium.copyWith(
                            color: status.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _getStatusDescription(status),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 2. Thông Tin Xe Thuê ──────────────────────────────────────────
            const _SectionHeader(
              title: 'Thông tin xe cho thuê',
              icon: Icons.directions_car_rounded,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: _currentBooking.vehicleImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: _currentBooking.vehicleImage,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.directions_car_filled_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.directions_car_filled_rounded,
                                color: AppColors.primary,
                              ),
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
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentWarm.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _currentBooking.licensePlate,
                            style: AppTypography.dataLabel.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đơn giá: ${_formatPrice(_currentBooking.pricePerDay)} đ/ngày',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 3. Thông Tin Lịch Trình ───────────────────────────────────────
            const _SectionHeader(
              title: 'Lịch trình thuê xe',
              icon: Icons.calendar_month_rounded,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                children: [
                  _InfoRowItem(
                    label: 'Thời gian nhận xe',
                    value: _formatDate(_currentBooking.startDate),
                    icon: Icons.access_time_rounded,
                  ),
                  const Divider(height: 18, color: AppColors.divider),
                  _InfoRowItem(
                    label: 'Thời gian trả xe',
                    value: _formatDate(_currentBooking.endDate),
                    icon: Icons.event_available_rounded,
                  ),
                  const Divider(height: 18, color: AppColors.divider),
                  _InfoRowItem(
                    label: 'Tổng thời gian thuê',
                    value: '${_currentBooking.totalDays} ngày',
                    icon: Icons.timer_outlined,
                  ),
                  if (_currentBooking.addressText.isNotEmpty) ...[
                    const Divider(height: 18, color: AppColors.divider),
                    _InfoRowItem(
                      label: 'Địa điểm giao nhận',
                      value: _currentBooking.addressText,
                      icon: Icons.place_outlined,
                      isMultiline: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 4. Thông Tin Khách Thuê ───────────────────────────────────────
            const _SectionHeader(
              title: 'Thông tin khách hàng',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                children: [
                  _InfoRowItem(
                    label: 'Họ và tên',
                    value: _currentBooking.renterName,
                    icon: Icons.badge_outlined,
                  ),
                  const Divider(height: 18, color: AppColors.divider),
                  _InfoRowItem(
                    label: 'Số điện thoại',
                    value: _currentBooking.renterPhone.isNotEmpty
                        ? _currentBooking.renterPhone
                        : 'Chưa có',
                    icon: Icons.phone_outlined,
                    trailing: _currentBooking.renterPhone.isNotEmpty
                        ? TapScale(
                            onTap: _callRenterPhone,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.call_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (_currentBooking.renterEmail.isNotEmpty) ...[
                    const Divider(height: 18, color: AppColors.divider),
                    _InfoRowItem(
                      label: 'Email',
                      value: _currentBooking.renterEmail,
                      icon: Icons.mail_outline_rounded,
                    ),
                  ],
                  if (_currentBooking.note != null && _currentBooking.note!.isNotEmpty) ...[
                    const Divider(height: 18, color: AppColors.divider),
                    _InfoRowItem(
                      label: 'Ghi chú',
                      value: _currentBooking.note!,
                      icon: Icons.notes_rounded,
                      isMultiline: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 5. Chi Tiết Thanh Toán ────────────────────────────────────────
            const _SectionHeader(
              title: 'Chi tiết chi phí',
              icon: Icons.receipt_long_rounded,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                children: [
                  _PriceRow(
                    label: 'Đơn giá thuê',
                    value: '${_formatPrice(_currentBooking.pricePerDay)} đ/ngày',
                  ),
                  const SizedBox(height: 10),
                  _PriceRow(
                    label: 'Số ngày thuê',
                    value: 'x ${_currentBooking.totalDays} ngày',
                  ),
                  const Divider(height: 22, color: AppColors.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng doanh thu dự kiến',
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${_formatPrice(_currentBooking.totalPrice)} đ',
                        style: AppTypography.priceLarge.copyWith(
                          fontSize: 18,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
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
      bottomSheet: _buildBottomActionBar(
        status,
        surfaceColor: surfaceColor,
        borderColor: borderColor,
        isDark: isDark,
      ),
    );
  }

  Widget? _buildBottomActionBar(BookingStatus status, {required Color surfaceColor, required Color borderColor, required bool isDark}) {
    if (status == BookingStatus.pending) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: AppButton(
                text: 'Từ chối',
                variant: AppButtonVariant.outline,
                height: 48,
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : _handleReject,
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.danger),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: AppButton(
                text: 'Duyệt & Ký HĐ',
                variant: AppButtonVariant.secondary,
                height: 48,
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : _handleApprove,
                icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
              ),
            ),
          ],
        ),
      );
    }

    if (status == BookingStatus.approved) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: _canMarkReceived ? 'Xác nhận khách đã nhận xe' : 'Chờ đến ngày nhận xe',
              width: double.infinity,
              height: 48,
              isLoading: _isProcessing,
              onPressed: _isProcessing || !_canMarkReceived ? null : _handleMarkReceived,
              icon: const Icon(Icons.directions_car_rounded, size: 18),
            ),
            if (!_canMarkReceived) ...[
              const SizedBox(height: 6),
              Text(
                'Nút này chỉ khả dụng khi tới ngày hẹn nhận xe.',
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
      );
    }

    if (status == BookingStatus.renting) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: _canMarkReturned ? 'Xác nhận khách đã trả xe' : 'Chờ đến lúc trả xe',
              width: double.infinity,
              height: 48,
              isLoading: _isProcessing,
              onPressed: _isProcessing || !_canMarkReturned ? null : _handleMarkReturned,
              icon: const Icon(Icons.done_all_rounded, size: 18),
            ),
            if (!_canMarkReturned) ...[
              const SizedBox(height: 6),
              Text(
                'Nút này chỉ khả dụng khi tới ngày trả xe.',
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
      );
    }

    return null;
  }

  String _getStatusDescription(BookingStatus st) {
    switch (st) {
      case BookingStatus.pending:
        return 'Khách hàng đang chờ bạn duyệt đơn và ký hợp đồng để chuẩn bị nhận xe.';
      case BookingStatus.approved:
        return 'Đơn đã được duyệt. Hãy chuẩn bị phương tiện để bàn giao đúng hẹn.';
      case BookingStatus.renting:
        return 'Khách hàng đang trong thời gian sử dụng xe theo hợp đồng.';
      case BookingStatus.completed:
        return 'Đơn thuê đã hoàn tất, xe đã được bàn giao lại an toàn.';
      case BookingStatus.rejected:
        return 'Đơn đặt thuê này đã bị từ chối.';
      case BookingStatus.cancelled:
        return 'Khách hàng đã hủy đơn thuê này.';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoRowItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isMultiline;
  final Widget? trailing;

  const _InfoRowItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isMultiline = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isMultiline ? 2.0 : 0.0),
          child: Icon(icon, size: 18, color: textMuted),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: EdgeInsets.only(top: isMultiline ? 1.0 : 0.0),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: trailing == null
              ? Text(
                  value,
                  textAlign: TextAlign.end,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: textSecondary),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}
