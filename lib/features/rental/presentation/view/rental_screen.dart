import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/rental/domain/usecases/cancel_booking.dart';
import 'package:book_drive_car/features/rental/domain/entities/rental_list_item_entity.dart';
import 'package:book_drive_car/features/rental/domain/usecases/get_renter_bookings.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_empty_state.dart';
import 'package:book_drive_car/shared/widget/app_shimmer.dart';
import 'package:book_drive_car/shared/widget/app_status_badge.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _FilterOption {
  final String label;
  final Set<String>? statuses;

  const _FilterOption(this.label, this.statuses);
}

class _RentalScreenState extends State<RentalScreen> {
  late final GetRenterBookings _getRenterBookings;

  final List<RentalListItemEntity> _bookings = [];
  Set<String>? _selectedFilter;
  bool _initialLoading = true;
  bool _refreshing = false;
  String? _errorMessage;
  Future<void>? _loadingOperation;

  static const _filters = <_FilterOption>[
    _FilterOption('Tất cả', null),
    _FilterOption('Chờ xác nhận', {'PENDING'}),
    _FilterOption('Đã xác nhận', {'APPROVED'}),
    _FilterOption('Đang thuê', {'RENTING', 'ONGOING'}),
    _FilterOption('Hoàn thành', {'COMPLETED'}),
    _FilterOption('Đã huỷ', {'CANCELLED', 'REJECTED'}),
  ];

  @override
  void initState() {
    super.initState();
    _getRenterBookings = sl<GetRenterBookings>();
    _scheduleInitialLoad();
  }

  void _scheduleInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_loadBookings(showRefreshing: false));
      }
    });
  }

  Future<void> _loadBookings({required bool showRefreshing}) async {
    if (_loadingOperation != null) {
      return _loadingOperation!;
    }

    final operation = _performLoad(showRefreshing: showRefreshing);
    _loadingOperation = operation;

    try {
      await operation;
    } finally {
      _loadingOperation = null;
    }
  }

  Future<void> _performLoad({required bool showRefreshing}) async {
    if (!mounted) return;

    setState(() {
      if (showRefreshing) {
        _refreshing = true;
      } else {
        _initialLoading = true;
      }
      _errorMessage = null;
    });

    try {
      debugPrint('[RentalScreen] load bookings start refresh=$showRefreshing');

      final bookings = await _getRenterBookings().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Tải đơn thuê quá lâu, vui lòng thử lại');
        },
      );

      debugPrint(
        '[RentalScreen] load bookings success count=${bookings.length}',
      );
      if (!mounted) return;
      setState(() {
        _bookings
          ..clear()
          ..addAll(bookings);
        _errorMessage = null;
      });
    } catch (e, st) {
      debugPrint('[RentalScreen] load bookings error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() {
        _errorMessage = _formatError(e);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        _refreshing = false;
      });
    }
  }

  String _formatError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  String _normalizeStatus(String status) {
    return status.trim().toUpperCase();
  }

  bool _matchesFilter(RentalListItemEntity booking) {
    if (_selectedFilter == null) return true;
    return _selectedFilter!.contains(_normalizeStatus(booking.status));
  }

  List<RentalListItemEntity> get _filteredBookings {
    return _bookings.where(_matchesFilter).toList();
  }

  String _statusLabel(String status) {
    switch (_normalizeStatus(status)) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'APPROVED':
        return 'Đã xác nhận';
      case 'RENTING':
      case 'ONGOING':
        return 'Đang thuê';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
      case 'REJECTED':
        return 'Đã huỷ';
      default:
        return status.isEmpty ? 'Không rõ' : status;
    }
  }

  Color _statusColor(String status) {
    switch (_normalizeStatus(status)) {
      case 'RENTING':
      case 'ONGOING':
        return AppColors.success;
      case 'COMPLETED':
        return AppColors.textSecondary;
      case 'CANCELLED':
      case 'REJECTED':
        return AppColors.danger;
      case 'APPROVED':
        return AppColors.primary;
      case 'PENDING':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (_normalizeStatus(status)) {
      case 'RENTING':
      case 'ONGOING':
        return Icons.directions_car_rounded;
      case 'PENDING':
        return Icons.hourglass_top_rounded;
      case 'APPROVED':
        return Icons.verified_rounded;
      case 'COMPLETED':
        return Icons.check_circle_rounded;
      case 'CANCELLED':
      case 'REJECTED':
        return Icons.cancel_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  String _statusNote(String status) {
    switch (_normalizeStatus(status)) {
      case 'RENTING':
      case 'ONGOING':
        return 'Vui lòng kiểm tra tình trạng xe trước khi trả. Nếu cần hỗ trợ trong chuyến đi, bạn có thể liên hệ chủ xe hoặc bộ phận hỗ trợ.';
      case 'PENDING':
        return 'Đơn của bạn đang chờ hệ thống xác nhận. Chúng tôi sẽ thông báo ngay khi có kết quả.';
      case 'APPROVED':
        return 'Đơn thuê đã được xác nhận. Bạn có thể xem lại lịch trình và chuẩn bị cho chuyến đi.';
      case 'COMPLETED':
        return 'Chuyến đi đã kết thúc. Cảm ơn bạn đã sử dụng dịch vụ, hẹn gặp lại ở chuyến tiếp theo!';
      case 'CANCELLED':
      case 'REJECTED':
        return 'Đơn này đã được hủy. Bạn có thể đặt lại xe này hoặc chọn xe khác bất cứ lúc nào.';
      default:
        return 'Thông tin đơn thuê đang được cập nhật.';
    }
  }

  bool _isConfirmedStatus(String status) {
    switch (_normalizeStatus(status)) {
      case 'APPROVED':
      case 'RENTING':
      case 'ONGOING':
      case 'COMPLETED':
        return true;
      default:
        return false;
    }
  }

  String _formatCurrency(num value) {
    return NumberFormat.decimalPattern('vi_VN').format(value);
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }

  String _vehicleSubtitle(RentalListItemEntity booking) {
    final vehicle = booking.vehicle;
    final parts = <String>[
      if (vehicle.brand.isNotEmpty) vehicle.brand,
      if (vehicle.model.isNotEmpty) vehicle.model,
      if (vehicle.year > 0) vehicle.year.toString(),
      if (vehicle.vehicleType.isNotEmpty) vehicle.vehicleType,
    ];
    return parts.join(' • ');
  }

  String? _vehicleLocation(RentalListItemEntity booking) {
    final address = booking.vehicle.address;
    final parts = <String>[
      address.addressDetail,
      address.ward,
      address.district,
      address.city,
    ].where((part) => part.trim().isNotEmpty).toList();

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  Future<void> _openBookingDetail(
    BuildContext context,
    RentalListItemEntity booking,
  ) async {
    final cancelled = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailSheet(
        booking: booking,
        color: _statusColor(booking.status),
        statusLabel: _statusLabel(booking.status),
        note: _statusNote(booking.status),
        formatCurrency: _formatCurrency,
        formatDateRange: _formatDateRange,
        vehicleSubtitle: _vehicleSubtitle(booking),
        vehicleLocation: _vehicleLocation(booking),
      ),
    );

    if (cancelled == true) {
      await _loadBookings(showRefreshing: true);
    }
  }

  String _listEmptyMessage() {
    if (_selectedFilter == null) {
      return 'Khi bạn đặt xe, các đơn thuê sẽ xuất hiện ở đây.';
    }
    return 'Không có đơn thuê nào khớp với bộ lọc hiện tại.';
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;
    final totalBookings = _bookings.length;
    final activeBookings = _bookings.where((booking) {
      final status = _normalizeStatus(booking.status);
      return status == 'RENTING' || status == 'ONGOING';
    }).length;
    final confirmedBookings = _bookings
        .where((booking) => _normalizeStatus(booking.status) == 'APPROVED')
        .length;
    final completedBookings = _bookings
        .where((booking) => _normalizeStatus(booking.status) == 'COMPLETED')
        .length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            StaggeredFadeIn(
              index: 0,
              child: _RentalHeroCard(
                title: 'Chuyến đi của tôi',
                subtitle:
                    'Theo dõi trạng thái chuyến đi, lịch thuê và thông tin chi phí thuận tiện.',
                totalBookings: totalBookings,
                activeBookings: activeBookings,
                confirmedBookings: confirmedBookings,
                completedBookings: completedBookings,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final filter = _filters[i];
                  final isSelected = _selectedFilter == filter.statuses;
                  return TapScale(
                    onTap: () =>
                        setState(() => _selectedFilter = filter.statuses),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : surfaceColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? primaryColor : borderColor,
                        ),
                        boxShadow: isSelected && !isDark
                            ? AppColors.shadowSm
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter.label,
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? (isDark
                                    ? AppColors.darkBackground
                                    : Colors.white)
                              : textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                onRefresh: () => _loadBookings(showRefreshing: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    if (_refreshing) ...[
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                        child: LinearProgressIndicator(
                          minHeight: 2.5,
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_initialLoading && _bookings.isEmpty)
                      Column(
                        children: List.generate(
                          3,
                          (_) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: AppShimmer(
                              width: double.infinity,
                              height: 140,
                              borderRadius: 20,
                            ),
                          ),
                        ),
                      )
                    else if (_errorMessage != null && _bookings.isEmpty)
                      AppEmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Không tải được đơn thuê',
                        subtitle: _errorMessage!,
                        buttonText: 'Thử lại',
                        onButtonPressed: () =>
                            _loadBookings(showRefreshing: true),
                      )
                    else if (bookings.isEmpty)
                      AppEmptyState(
                        icon: Icons.calendar_month_rounded,
                        title: 'Chưa có đơn thuê nào',
                        subtitle: _listEmptyMessage(),
                      )
                    else
                      ...List.generate(bookings.length, (index) {
                        final booking = bookings[index];
                        final status = _normalizeStatus(booking.status);
                        final isDimmed =
                            status == 'CANCELLED' || status == 'REJECTED';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: StaggeredFadeIn(
                            index: 1 + index,
                            child: Opacity(
                              opacity: isDimmed ? 0.65 : 1.0,
                              child: TapScale(
                                onTap: () =>
                                    _openBookingDetail(context, booking),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderColor),
                                    boxShadow: isDark
                                        ? null
                                        : AppColors.shadowSm,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppStatusBadge.fromStatus(
                                            booking.status,
                                          ),
                                          Text(
                                            booking.bookingCode.isNotEmpty
                                                ? booking.bookingCode
                                                : '#${booking.id}',
                                            style: AppTypography.dataLabel
                                                .copyWith(
                                                  color: isDark
                                                      ? AppColors.darkTextMuted
                                                      : AppColors.textMuted,
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        booking.vehicle.vehicleName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.titleMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _vehicleSubtitle(booking),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: textSecondary,
                                        ),
                                      ),
                                      Divider(height: 22, color: borderColor),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.date_range_rounded,
                                                size: 15,
                                                color: primaryColor,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                _formatDateRange(
                                                  booking.startDate,
                                                  booking.endDate,
                                                ),
                                                style: AppTypography.bodySmall
                                                    .copyWith(
                                                      color: textPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${_formatCurrency(booking.totalAmount)}đ',
                                            style: AppTypography.priceMedium
                                                .copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
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

class _BookingDetailSheet extends StatelessWidget {
  final RentalListItemEntity booking;
  final Color color;
  final String statusLabel;
  final String note;
  final String Function(num value) formatCurrency;
  final String Function(DateTime start, DateTime end) formatDateRange;
  final String vehicleSubtitle;
  final String? vehicleLocation;

  const _BookingDetailSheet({
    required this.booking,
    required this.color,
    required this.statusLabel,
    required this.note,
    required this.formatCurrency,
    required this.formatDateRange,
    required this.vehicleSubtitle,
    required this.vehicleLocation,
  });

  static const String _supportPhoneNumber = '0832235031';

  String _normalizeStatus(String status) {
    return status.trim().toUpperCase();
  }

  bool _isConfirmedStatus(String status) {
    switch (_normalizeStatus(status)) {
      case 'APPROVED':
      case 'RENTING':
      case 'ONGOING':
      case 'COMPLETED':
        return true;
      default:
        return false;
    }
  }

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  DateTime get _startDate => DateUtils.dateOnly(booking.startDate);

  DateTime get _endDate => DateUtils.dateOnly(booking.endDate);

  bool get _isAfterEndDate => _today.isAfter(_endDate);

  bool get _canCancelBooking {
    final status = _normalizeStatus(booking.status);
    // Cho phép hủy khi đơn ở trạng thái PENDING (chờ duyệt) hoặc APPROVED (đã duyệt, trừ 10%)
    if (status == 'PENDING' || status == 'APPROVED') {
      return !_isAfterEndDate;
    }
    return false;
  }

  bool get _isFinal {
    final status = booking.status.trim().toUpperCase();
    return status == 'COMPLETED' ||
        status == 'CANCELLED' ||
        status == 'REJECTED';
  }

  String _cancelDisabledReason() {
    final status = _normalizeStatus(booking.status);
    if (status == 'APPROVED') {
      return 'Đơn thuê đã được duyệt nên bạn không thể hủy trực tiếp. Vui lòng liên hệ hỗ trợ hoặc chủ xe.';
    }
    if (status == 'RENTING' || status == 'ONGOING') {
      return 'Đơn thuê đang trong quá trình thuê xe nên không thể hủy.';
    }
    if (status == 'COMPLETED') {
      return 'Đơn thuê đã hoàn thành nên không thể hủy.';
    }
    if (status == 'CANCELLED' || status == 'REJECTED') {
      return 'Đơn thuê đã kết thúc.';
    }
    if (_isAfterEndDate) {
      return 'Đơn thuê đã quá ngày kết thúc nên không thể hủy.';
    }
    return 'Không thể hủy đơn thuê này.';
  }

  String _cancelDialogMessage() {
    final status = _normalizeStatus(booking.status);
    if (status == 'PENDING') {
      return 'Đơn thuê chưa được xác nhận, vì vậy bạn sẽ không mất tiền nếu hủy đơn. Bạn có muốn tiếp tục hủy đơn thuê không?';
    }
    if (status == 'APPROVED') {
      return 'Đơn thuê đã được duyệt, nếu hủy bạn sẽ bị trừ 10% số tiền theo chính sách hủy đơn. Bạn có chắc chắn muốn tiếp tục hủy đơn thuê không?';
    }
    if (status == 'RENTING' || status == 'ONGOING') {
      return 'Đơn thuê đang ở trạng thái đang thuê nên bạn không thể hủy nữa. Vui lòng liên hệ chủ xe nếu cần hỗ trợ.';
    }
    return 'Bạn có muốn hủy đơn thuê này không?';
  }

  Future<void> _cancelBooking(BuildContext context) async {
    if (!_canCancelBooking) return;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận hủy đơn'),
          content: Text(_cancelDialogMessage()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Có, hủy đơn'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !context.mounted) {
      return;
    }

    try {
      await sl<CancelBooking>().call(booking.id);

      if (!context.mounted) return;
      AppToast.show(
        context,
        message: 'Đã hủy đơn thuê thành công',
        type: AppToastType.success,
      );
      Navigator.of(context).pop(true);
      debugPrint(
        '[RentalScreen] cancel booking success bookingId=${booking.id} bookingCode=${booking.bookingCode}',
      );
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AppToastType.error,
      );
    }
  }

  Future<void> _callSupport(BuildContext context, {String? phoneNumber}) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber ?? _supportPhoneNumber);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng gọi điện')),
      );
    }
  }

  Future<void> _confirmCancelBooking(BuildContext context) async {
    await _cancelBooking(context);
  }

  Widget _buildImageCarousel() {
    final images = booking.vehicle.imageUrls
        .where((url) => url.trim().isNotEmpty)
        .toList();

    return StatefulBuilder(
      builder: (context, setState) {
        var currentIndex = 0;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: images.isEmpty
                ? Container(
                    color: AppColors.background,
                    child: const Center(
                      child: Icon(
                        Icons.directions_car_rounded,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : StatefulBuilder(
                    builder: (context, innerSetState) {
                      return Stack(
                        children: [
                          PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (index) {
                              currentIndex = index;
                              innerSetState(() {});
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.background,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      size: 48,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${currentIndex + 1}/${images.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (images.length > 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Vuốt sang ngang để xem ảnh',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                BookingImageCarousel(images: booking.vehicle.imageUrls),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        booking.vehicle.vehicleName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (_isConfirmedStatus(booking.status) &&
                    (booking.vehicle.ownerName?.trim().isNotEmpty == true ||
                        booking.vehicle.ownerPhone?.trim().isNotEmpty ==
                            true)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Chủ xe',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (booking.vehicle.ownerName?.trim().isNotEmpty ==
                            true)
                          _DetailRow(
                            label: 'Họ và tên',
                            value: booking.vehicle.ownerName!,
                          ),
                        if (booking.vehicle.ownerPhone?.trim().isNotEmpty ==
                            true)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Điện thoại',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      onTap: () => _callSupport(
                                        context,
                                        phoneNumber: booking.vehicle.ownerPhone,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.call_rounded,
                                              size: 15,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              booking.vehicle.ownerPhone!,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  vehicleSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          'Trạng thái',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Mã đơn hàng',
                  value: booking.bookingCode.isNotEmpty
                      ? booking.bookingCode
                      : '#${booking.id}',
                ),
                _DetailRow(
                  label: 'Tổng chi phí',
                  value: '${formatCurrency(booking.totalAmount)}đ',
                ),
                _DetailRow(
                  label: 'Số ngày thuê',
                  value: '${booking.totalDays} ngày',
                ),
                _DetailRow(
                  label: 'Đơn giá / ngày',
                  value: booking.pricePerDay != null
                      ? '${formatCurrency(booking.pricePerDay!)}đ'
                      : 'Chưa có dữ liệu',
                ),
                _DetailRow(
                  label: 'Lịch trình',
                  value: formatDateRange(booking.startDate, booking.endDate),
                ),
                if (vehicleLocation != null)
                  _DetailRow(label: 'Khu vực', value: vehicleLocation!),
                _DetailRow(
                  label: 'Ngày hiện tại',
                  value: DateFormat('dd/MM/yyyy').format(_today),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: color.withOpacity(0.08),
                    border: Border.all(color: color.withOpacity(0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_rounded, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          note,
                          style: TextStyle(
                            color: color.withOpacity(0.95),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => _callSupport(context),
                        icon: const Icon(Icons.support_agent_rounded, size: 20),
                        label: const Text(
                          'Liên hệ hỗ trợ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _canCancelBooking
                              ? AppColors.danger
                              : AppColors.textMuted,
                          backgroundColor: _canCancelBooking
                              ? AppColors.danger.withOpacity(0.06)
                              : AppColors.background,
                          side: BorderSide(
                            color: _canCancelBooking
                                ? AppColors.danger.withOpacity(0.35)
                                : AppColors.border,
                            width: 1.4,
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          if (!_canCancelBooking) {
                            AppToast.show(
                              context,
                              message: _cancelDisabledReason(),
                              type: AppToastType.warning,
                            );
                            return;
                          }
                          _confirmCancelBooking(context);
                        },
                        icon: Icon(
                          _canCancelBooking
                              ? Icons.cancel_rounded
                              : Icons.lock_rounded,
                          size: 19,
                        ),
                        label: Text(
                          _canCancelBooking ? 'Hủy đơn' : 'Không thể hủy',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BookingImageCarousel extends StatefulWidget {
  final List<String> images;

  const BookingImageCarousel({super.key, required this.images});

  @override
  State<BookingImageCarousel> createState() => _BookingImageCarouselState();
}

class _BookingImageCarouselState extends State<BookingImageCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.where((url) => url.trim().isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: images.isEmpty
            ? Container(
                color: AppColors.background,
                child: const Center(
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 52,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      if (!mounted) return;
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.background,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_currentIndex + 1}/${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (images.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Vuốt sang ngang để xem ảnh',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowBg = isDark
        ? AppColors.darkSurfaceSecondary
        : AppColors.surfaceSecondary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: valueColor ?? textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryBackground extends StatelessWidget {
  const _LuxuryBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1017), Color(0xFF151A24), Color(0xFFF7F8FA)],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -92,
            right: -64,
            child: _LuxuryGlow(
              size: 230,
              colors: [
                AppColors.headlightAmber.withValues(alpha: 0.22),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 156,
            left: -72,
            child: _LuxuryGlow(
              size: 180,
              colors: [
                AppColors.pageAccents[2].withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryGlow extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _LuxuryGlow({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _RentalHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int totalBookings;
  final int activeBookings;
  final int confirmedBookings;
  final int completedBookings;

  const _RentalHeroCard({
    required this.title,
    required this.subtitle,
    required this.totalBookings,
    required this.activeBookings,
    required this.confirmedBookings,
    required this.completedBookings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF06111C),
                  const Color(0xFF0B1F33),
                  const Color(0xFF13324F),
                ]
              : [
                  const Color(0xFF082236),
                  AppColors.primary,
                  const Color(0xFF1B4F72),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(
              alpha: 0.28,
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkAccent : AppColors.accent)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? AppColors.darkAccent : AppColors.accent)
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: isDark ? AppColors.darkAccent : AppColors.accentLight,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatChip(label: '$totalBookings', caption: 'Tổng đơn'),
              _HeroStatChip(label: '$activeBookings', caption: 'Đang đi'),
              _HeroStatChip(
                label: '$confirmedBookings',
                caption: 'Đã xác nhận',
              ),
              _HeroStatChip(label: '$completedBookings', caption: 'Hoàn thành'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dữ liệu chuyến đi được cập nhật trực tiếp từ hệ thống của bạn.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  final String label;
  final String caption;

  const _HeroStatChip({required this.label, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onAction;

  const _LuxuryMessageCard({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionColor,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (actionColor ?? AppColors.primary).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: actionColor ?? AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor ?? AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
