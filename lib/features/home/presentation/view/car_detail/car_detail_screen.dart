import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';
import 'package:book_drive_car/features/home/data/datasources/booking_remote_data_source.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/widgets/car_detail_booking_modal_sheet.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/widgets/car_detail_date_picker_sheet.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/widgets/car_detail_header_widgets.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_owner_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_review_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_spec_grid.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_terms_card.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_local_datasource.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/identity_verification_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarDetailScreen extends StatefulWidget {
  final CarEntity car;

  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  int _currentImage = 0;
  bool _isFavorite = false;
  DateTimeRange? _selectedDateRange;

  CarEntity get car => widget.car;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = null;
  }

  String _formatPrice(num price) {
    final s = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buffer.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return '${buffer.toString()}đ';
  }

  int get _rentalDays {
    if (_selectedDateRange == null) return 1;
    final days = _selectedDateRange!.duration.inDays;
    return days < 1 ? 1 : days;
  }

  int get _totalPrice {
    return car.pricePerDay * _rentalDays;
  }

  String _formatBookingRange(DateTimeRange range) {
    final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  String _formatBookingRangeWithTime(DateTimeRange range) {
    final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    return 'từ 00h ngày ${formatter.format(range.start)} - 00h ngày ${formatter.format(range.end)}';
  }

  DateTime _dateOnly(DateTime value) => DateUtils.dateOnly(value);

  int? get _vehicleId => int.tryParse(car.id);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekdayShortLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
      default:
        return 'CN';
    }
  }

  String _monthLabel(DateTime month) {
    return 'Tháng ${month.month}/${month.year}';
  }

  List<DateTime?> _daysForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final leadingEmpty = firstDay.weekday - DateTime.monday;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leadingEmpty, null),
      for (int i = 0; i < daysInMonth; i++)
        DateTime(month.year, month.month, i + 1),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  Future<DateTimeRange?> _pickDateRange(BuildContext context) async {
    final vehicleId = _vehicleId;
    if (vehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không lấy được mã xe để kiểm tra lịch đã đặt.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }

    final now = _dateOnly(DateTime.now());
    final firstDay = _selectedDateRange?.start ?? now;
    final lastDay = _selectedDateRange?.end ?? now.add(const Duration(days: 1));
    final hasInitialSelection = _selectedDateRange != null;

    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return CarDetailDatePickerSheet(
          vehicleId: vehicleId,
          bookingRemoteDataSource: sl<BookingRemoteDataSource>(),
          initialStart: firstDay.isBefore(now) ? now : _dateOnly(firstDay),
          initialEnd: lastDay.isBefore(now.add(const Duration(days: 1)))
              ? now.add(const Duration(days: 1))
              : _dateOnly(lastDay),
          hasInitialSelection: hasInitialSelection,
          minDate: now,
          maxDate: now.add(const Duration(days: 90)),
          dateOnly: _dateOnly,
          isSameDay: _isSameDay,
          weekdayShortLabel: _weekdayShortLabel,
          monthLabel: _monthLabel,
          daysForMonth: _daysForMonth,
          formatBookingRange: _formatBookingRange,
          formatBookingRangeWithTime: _formatBookingRangeWithTime,
        );
      },
    );
  }

  Future<void> _handleBookingFlow(BuildContext context) async {
    final vData = await sl<VerificationLocalDataSource>().getVerificationData();
    if (vData.status != VerificationStatus.verified) {
      if (!context.mounted) return;
      _showVerificationRequiredDialog(context, vData);
      return;
    }

    if (vData.licenseExpiryDate != null && vData.licenseExpiryDate!.isNotEmpty) {
      try {
        final parts = vData.licenseExpiryDate!.split('/');
        if (parts.length == 3) {
          final expiry = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          if (expiry.isBefore(DateTime.now())) {
            if (!context.mounted) return;
            _showVerificationRequiredDialog(context, vData, isExpired: true);
            return;
          }
        }
      } catch (_) {}
    }

    if (!context.mounted) return;
    if (_selectedDateRange == null) {
      final pickedRange = await _pickDateRange(context);
      if (pickedRange == null) return;
      setState(() => _selectedDateRange = pickedRange);
    }

    if (!context.mounted) return;
    CarDetailBookingModalSheet.show(
      context: context,
      car: car,
      selectedDateRange: _selectedDateRange!,
      rentalDays: _rentalDays,
      totalPrice: _totalPrice,
      formatPrice: _formatPrice,
    );
  }

  void _showVerificationRequiredDialog(BuildContext context, VerificationData vData, {bool isExpired = false}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.headlightAmber),
            SizedBox(width: 8),
            Text('Xác minh tài khoản', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          isExpired
              ? 'Giấy phép lái xe của bạn đã hết hạn. Vui lòng cập nhật GPLX mới để tiếp tục đặt thuê xe.'
              : 'Bạn cần hoàn thành Xác minh danh tính & Giấy phép lái xe (KYC) trước khi bắt đầu thuê xe trên hệ thống.',
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Để sau', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => IdentityVerificationScreen(initialData: vData),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Xác minh ngay', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = car.imageUrls.isNotEmpty ? car.imageUrls : [car.imageIcon];
    final hasImages = images.any((e) => e.startsWith('http'));

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: LuxuryCarDetailBackground()),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: context.isTablet ? 420 : 310,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: GlassIconButton(
                      icon: _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _isFavorite ? Colors.redAccent : Colors.white,
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isFavorite
                                  ? 'Đã thêm vào yêu thích'
                                  : 'Đã xóa khỏi yêu thích',
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GlassIconButton(
                      icon: Icons.share_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Chia sẻ thông tin xe ${car.name}'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasImages)
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (i) => setState(() => _currentImage = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: images[i],
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) => Container(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              child: const Icon(
                                Icons.directions_car_filled_outlined,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0F141B), Color(0xFF16202B)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              size: 96,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.55),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.70),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              '${_currentImage + 1}/${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isTablet ? 32 : 18,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên xe & Đánh giá
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        car.vehicleType,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${car.rating} (Đánh giá cao)',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatPrice(car.pricePerDay),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Text(
                                '/ ngày',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Chọn thời gian thuê xe
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Thời gian thuê xe',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                final picked = await _pickDateRange(context);
                                if (picked != null) {
                                  setState(() => _selectedDateRange = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedDateRange != null
                                            ? _formatBookingRange(_selectedDateRange!)
                                            : 'Chạm để chọn ngày nhận & trả xe',
                                        style: TextStyle(
                                          color: _selectedDateRange != null ? Colors.white : Colors.white54,
                                          fontWeight: _selectedDateRange != null ? FontWeight.w700 : FontWeight.normal,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Thông số kỹ thuật
                      const SectionTitle(title: 'Thông số kỹ thuật'),
                      const SizedBox(height: 12),
                      CarDetailSpecGrid(
                        specs: [
                          SpecItem(icon: Icons.airline_seat_recline_normal_rounded, label: 'Số chỗ', value: '${car.seats} chỗ'),
                          SpecItem(icon: Icons.local_gas_station_rounded, label: 'Nhiên liệu', value: car.fuelType ?? 'Xăng'),
                          SpecItem(icon: Icons.settings_rounded, label: 'Hộp số', value: car.transmission ?? 'Tự động'),
                          const SpecItem(icon: Icons.speed_rounded, label: 'Mức tiêu hao', value: '7.5L / 100km'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Chủ xe & Đánh giá & Điều khoản
                      const CarDetailOwnerCard(),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Đánh giá từ khách hàng'),
                      const SizedBox(height: 12),
                      const CarDetailReviewCard(
                        name: 'Nguyễn Văn Minh',
                        date: '12/03/2026',
                        rating: 5.0,
                        comment: 'Xe rất mới, sạch sẽ và máy chạy cực êm. Chủ xe nhiệt tình, thủ tục giao nhận nhanh gọn!',
                      ),
                      const SizedBox(height: 24),
                      const CarDetailTermsCard(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF151A24),
                border: const Border(top: BorderSide(color: Colors.white12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng tạm tính',
                        style: TextStyle(fontSize: 11.5, color: Colors.white54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatPrice(_totalPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _handleBookingFlow(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Đặt xe ngay',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
