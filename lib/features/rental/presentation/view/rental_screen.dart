import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/rental/domain/entities/rental_list_item_entity.dart';
import 'package:book_drive_car/features/rental/domain/usecases/get_renter_bookings.dart';
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
    await showModalBottomSheet<void>(
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

    return Column(
      children: [
        StaggeredFadeIn(
          index: 0,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.96),
                  AppColors.accent.withOpacity(0.92),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chuyến đi của tôi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Theo dõi trạng thái chuyến đi, lịch thuê và thông tin thanh toán thật rõ ràng.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final filter = _filters[i];
              final isSelected = _selectedFilter == filter.statuses;
              return TapScale(
                onTap: () => setState(() => _selectedFilter = filter.statuses),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _loadBookings(showRefreshing: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                if (_refreshing) ...[
                  const SizedBox(height: 4),
                  const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                    child: LinearProgressIndicator(minHeight: 2.5),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_initialLoading && _bookings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Đang tải danh sách đơn thuê...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_errorMessage != null && _bookings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _loadBookings(showRefreshing: true),
                            child: const Text('Thử lại'),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (bookings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có đơn thuê nào',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _listEmptyMessage(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(bookings.length, (index) {
                    final booking = bookings[index];
                    final statusColor = _statusColor(booking.status);
                    final status = _normalizeStatus(booking.status);
                    final isDimmed =
                        status == 'CANCELLED' || status == 'REJECTED';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StaggeredFadeIn(
                        index: 1 + index,
                        child: Opacity(
                          opacity: isDimmed ? 0.6 : 1,
                          child: TapScale(
                            onTap: () => _openBookingDetail(context, booking),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: AppColors.border.withOpacity(0.8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0F172A,
                                    ).withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          _statusIcon(booking.status),
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              booking.vehicle.vehicleName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Mã đơn: ${booking.bookingCode.isNotEmpty ? booking.bookingCode : '#${booking.id}'}',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          _statusLabel(booking.status),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppColors.border.withOpacity(
                                            0.6,
                                          ),
                                        ),
                                        bottom: BorderSide(
                                          color: AppColors.border.withOpacity(
                                            0.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'THỜI GIAN',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary
                                                      .withOpacity(0.8),
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDateRange(
                                                  booking.startDate,
                                                  booking.endDate,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'TỔNG TIỀN',
                                              style: TextStyle(
                                                color: AppColors.textSecondary
                                                    .withOpacity(0.8),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_formatCurrency(booking.totalAmount)}đ',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.place_rounded,
                                              size: 15,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              booking
                                                      .vehicle
                                                      .address
                                                      .city
                                                      .isNotEmpty
                                                  ? booking.vehicle.address.city
                                                  : 'Không có địa chỉ',
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Chi tiết',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 15,
                                            color: AppColors.primary,
                                          ),
                                        ],
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
    final status = booking.status.trim().toUpperCase();
    if (status == 'COMPLETED' ||
        status == 'CANCELLED' ||
        status == 'REJECTED') {
      return false;
    }
    return !_isAfterEndDate;
  }

  bool get _needsCancelConfirmation {
    if (!_canCancelBooking) return false;
    return !_today.isAfter(_endDate);
  }

  bool get _isFinal {
    final status = booking.status.trim().toUpperCase();
    return status == 'COMPLETED' ||
        status == 'CANCELLED' ||
        status == 'REJECTED';
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
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận hủy đơn'),
          content: const Text(
            'Khi hủy đơn thuê bạn sẽ mất 10% số tiền. Bạn có muốn hủy đơn thuê?',
          ),
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

    if (shouldCancel == true && context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xác nhận hủy đơn thuê.')),
      );
      debugPrint(
        '[RentalScreen] cancel booking requested bookingId=${booking.id} bookingCode=${booking.bookingCode}',
      );
    }
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      color: AppColors.border,
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
                        booking.vehicle.ownerPhone?.trim().isNotEmpty == true)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border.withOpacity(0.8)),
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
                        if (booking.vehicle.ownerName?.trim().isNotEmpty == true)
                          _DetailRow(
                            label: 'Họ và tên',
                            value: booking.vehicle.ownerName!,
                          ),
                        if (booking.vehicle.ownerPhone?.trim().isNotEmpty == true)
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
                                const Expanded(
                                  child: Text(
                                    'Điện thoại',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _callSupport(
                                    context,
                                    phoneNumber: booking.vehicle.ownerPhone,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.call_rounded,
                                          size: 16,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trạng thái',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
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
                        onPressed: _canCancelBooking
                            ? () {
                                if (_needsCancelConfirmation) {
                                  _confirmCancelBooking(context);
                                }
                              }
                            : null,
                        icon: Icon(
                          _canCancelBooking
                              ? Icons.cancel_rounded
                              : Icons.lock_rounded,
                          size: 19,
                        ),
                        label: Text(
                          _canCancelBooking ? 'Hủy đơn' : 'Đã quá hạn hủy',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
