import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/features/home/data/datasources/booking_remote_data_source.dart';
import 'package:book_drive_car/features/home/domain/entities/booking_request_entity.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/booking_contract_flow.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:book_drive_car/features/home/presentation/widget/car_detail_review_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_spec_grid.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_terms_card.dart';
import 'package:flutter/material.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';
import 'package:intl/intl.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';

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

  String _extractBookingErrorMessage(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
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
        return _DateRangePickerSheet(
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

  @override
  Widget build(BuildContext context) {
    final images = car.imageUrls.isNotEmpty ? car.imageUrls : [car.imageIcon];
    final hasImages = images.any((e) => e.startsWith('http'));

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _LuxuryCarDetailBackground()),
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
                  child: _GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: _GlassIconButton(
                      icon: _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _isFavorite ? Colors.redAccent : Colors.white,
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
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
                    child: _GlassIconButton(
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
                          onPageChanged: (i) =>
                              setState(() => _currentImage = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: images[i],
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF0B0F15)
                                        .withValues(alpha: 0.10),
                                    Colors.transparent,
                                    const Color(0xFF0B0F15)
                                        .withValues(alpha: 0.76),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 90,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Text(
                                  car.brand.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 110,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      const Color(0xFF0C1017)
                                          .withValues(alpha: 0.88),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (images.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(images.length, (i) {
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      width: _currentImage == i ? 22 : 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: _currentImage == i
                                            ? AppColors.headlightAmber
                                            : Colors.white.withValues(
                                                alpha: 0.55,
                                              ),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.name,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.laneWhite,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        car.vehicleType,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    if (car.licensePlate != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.shade400,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          car.licensePlate!,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7D5A00),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    car.location.isNotEmpty
                                        ? car.location
                                        : car.province,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Cách bạn khoảng ${car.distanceKm.toStringAsFixed(1)} km',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Thông số kỹ thuật'),
                      const SizedBox(height: 12),
                      CarDetailSpecGrid(
                        specs: [
                          SpecItem(
                            icon: Icons.apartment_outlined,
                            label: 'Hãng xe',
                            value: car.brand,
                          ),
                          SpecItem(
                            icon: Icons.directions_car_outlined,
                            label: 'Loại xe',
                            value: car.vehicleType,
                          ),
                          SpecItem(
                            icon: Icons.people_alt_outlined,
                            label: 'Số chỗ',
                            value: '${car.seats} chỗ',
                          ),
                          SpecItem(
                            icon: Icons.settings_suggest_outlined,
                            label: 'Hộp số',
                            value: car.transmission ?? 'Tự động',
                          ),
                          SpecItem(
                            icon: Icons.local_gas_station_outlined,
                            label: 'Nhiên liệu',
                            value: car.fuelType ?? 'Xăng',
                          ),
                          if (car.year != null)
                            SpecItem(
                              icon: Icons.calendar_today_outlined,
                              label: 'Năm sản xuất',
                              value: '${car.year}',
                            ),
                          if (car.color != null)
                            SpecItem(
                              icon: Icons.palette_outlined,
                              label: 'Màu xe',
                              value: car.color!,
                            ),
                          if (car.model != null)
                            SpecItem(
                              icon: Icons.time_to_leave_outlined,
                              label: 'Model',
                              value: car.model!,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Tiện nghi trên xe'),
                      const SizedBox(height: 12),
                      const Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FeatureChip(
                            icon: Icons.bluetooth_rounded,
                            label: 'Bluetooth',
                          ),
                          FeatureChip(
                            icon: Icons.map_outlined,
                            label: 'Bản đồ GPS',
                          ),
                          FeatureChip(
                            icon: Icons.videocam_outlined,
                            label: 'Camera lùi',
                          ),
                          FeatureChip(
                            icon: Icons.ac_unit_rounded,
                            label: 'Điều hòa 2 vùng',
                          ),
                          FeatureChip(
                            icon: Icons.key_rounded,
                            label: 'Smartkey',
                          ),
                          FeatureChip(
                            icon: Icons.speed_rounded,
                            label: 'Cruise Control',
                          ),
                          FeatureChip(
                            icon: Icons.child_care_rounded,
                            label: 'Ghế trẻ em',
                          ),
                          FeatureChip(
                            icon: Icons.usb_rounded,
                            label: 'Cổng sạc USB',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (car.description?.isNotEmpty == true) ...[
                        const _SectionTitle(title: 'Mô tả chi tiết'),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            car.description!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const _SectionTitle(
                        title: 'Giấy tờ & Điều khoản thuê xe',
                      ),
                      const SizedBox(height: 12),
                      const CarDetailTermsCard(),
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Đánh giá từ khách hàng (24)'),
                      const SizedBox(height: 12),
                      const CarDetailReviewCard(
                        name: 'Nguyễn Văn Minh',
                        date: '02/08/2026',
                        rating: 5.0,
                        comment:
                            'Xe mới, sạch sẽ, máy êm. Chủ xe giao nhận đúng giờ và nhiệt tình!',
                      ),
                      const SizedBox(height: 10),
                      const CarDetailReviewCard(
                        name: 'Trần Thị Thu',
                        date: '28/07/2026',
                        rating: 4.8,
                        comment:
                            'Chuyến đi tuyệt vời, xe tiết kiệm nhiên liệu. Sẽ quay lại thuê tiếp.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF101521),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
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
                          'Giá thuê 1 ngày',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatPrice(car.pricePerDay),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.headlightAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC36C), Color(0xFFEA9B2D)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.headlightAmber.withValues(
                                alpha: 0.32,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _showBookingBottomSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đặt xe ngay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.black,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Modal Bottom Sheet Đặt Xe Chi Tiết ─────────────────────────────────────
  void _showBookingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isSubmittingBooking = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submitBooking() async {
              if (isSubmittingBooking) return;

              if (_selectedDateRange == null) {
                AppToast.show(
                  null,
                  message: 'Vui lòng chọn thời gian thuê xe',
                  type: AppToastType.error,
                );
                return;
              }

              final vehicleId = _vehicleId;
              if (vehicleId == null) {
                AppToast.show(
                  null,
                  message: 'Không lấy được mã xe để gửi booking lên server.',
                  type: AppToastType.error,
                );
                return;
              }

              setModalState(() {
                isSubmittingBooking = true;
              });

              try {
                final bookingRemoteDataSource = sl<BookingRemoteDataSource>();
                final verifiedUser = await bookingRemoteDataSource.checkVerified();

                debugPrint(
                  '[BookingSubmit] vehicleId=$vehicleId start=${_selectedDateRange!.start.toIso8601String()} end=${_selectedDateRange!.end.toIso8601String()}',
                );

                final bookingResult =
                    await Navigator.of(context).push<Object?>(
                  MaterialPageRoute(
                    builder: (_) => BookingContractScreen(
                      car: car,
                      request: BookingRequestEntity(
                        vehicleId: vehicleId,
                        startDate: _selectedDateRange!.start,
                        endDate: _selectedDateRange!.end,
                        note: '',
                      ),
                      renter: verifiedUser,
                    ),
                  ),
                );

                if (bookingResult == null) {
                  setModalState(() {
                    isSubmittingBooking = false;
                  });
                  return;
                }

                if (!context.mounted) return;
                Navigator.of(context).pop();
                AppToast.show(
                  null,
                  message:
                      'Đặt xe thành công! Vui lòng vào "Đơn thuê" để kiểm tra thông tin.',
                  type: AppToastType.success,
                );
              } catch (e) {
                if (!context.mounted) return;
                final errorMessage = _extractBookingErrorMessage(e);
                debugPrint('[BookingSubmit] error=$errorMessage');
                AppToast.show(
                  context,
                  message: errorMessage,
                  type: AppToastType.error,
                );
                setModalState(() {
                  isSubmittingBooking = false;
                });
              }
            }

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
                    'Xác nhận đặt xe ${car.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn số ngày thuê
                  const Text(
                    'Thời gian thuê xe',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await _pickDateRange(context);
                      if (picked != null) {
                        setState(() => _selectedDateRange = picked);
                        setModalState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.date_range_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedDateRange == null
                                  ? 'Vui lòng chọn thời gian thuê xe'
                                  : '${_formatBookingRange(_selectedDateRange!)} ($_rentalDays ngày)',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.edit_calendar_rounded,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bảng tính tổng phí
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đơn giá thuê (1 ngày)',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _formatPrice(car.pricePerDay),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Số ngày thuê',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$_rentalDays ngày',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng tiền tạm tính',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _formatPrice(_totalPrice),
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
                  const SizedBox(height: 20),

                  // Nút xác nhận
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmittingBooking ? null : submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSubmittingBooking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Xác nhận đặt xe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LuxuryCarDetailBackground extends StatelessWidget {
  const _LuxuryCarDetailBackground();

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
            top: -90,
            right: -70,
            child: _LuxuryGlow(
              size: 240,
              colors: [
                AppColors.headlightAmber.withValues(alpha: 0.20),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 160,
            left: -80,
            child: _LuxuryGlow(
              size: 180,
              colors: [
                AppColors.pageAccents[2].withValues(alpha: 0.15),
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _DateRangePickerSheet extends StatefulWidget {
  final int vehicleId;
  final BookingRemoteDataSource bookingRemoteDataSource;
  final DateTime initialStart;
  final DateTime initialEnd;
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime Function(DateTime) dateOnly;
  final bool Function(DateTime, DateTime) isSameDay;
  final bool hasInitialSelection;
  final String Function(int weekday) weekdayShortLabel;
  final String Function(DateTime month) monthLabel;
  final List<DateTime?> Function(DateTime month) daysForMonth;
  final String Function(DateTimeRange range) formatBookingRange;
  final String Function(DateTimeRange range) formatBookingRangeWithTime;

  const _DateRangePickerSheet({
    required this.vehicleId,
    required this.bookingRemoteDataSource,
    required this.initialStart,
    required this.initialEnd,
    required this.hasInitialSelection,
    required this.minDate,
    required this.maxDate,
    required this.dateOnly,
    required this.isSameDay,
    required this.weekdayShortLabel,
    required this.monthLabel,
    required this.daysForMonth,
    required this.formatBookingRange,
    required this.formatBookingRangeWithTime,
  });

  @override
  State<_DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<_DateRangePickerSheet> {
  late DateTime _focusedMonth;
  DateTime? _startDate;
  late DateTime? _endDate;
  bool _isLoadingBlockedRanges = true;
  String? _loadError;
  List<DateTimeRange> _blockedRanges = [];

  @override
  void initState() {
    super.initState();
    _startDate = widget.hasInitialSelection
        ? widget.dateOnly(widget.initialStart)
        : null;
    _endDate = widget.hasInitialSelection
        ? widget.dateOnly(widget.initialEnd)
        : null;
    final focusDate = _startDate ?? widget.dateOnly(DateTime.now());
    _focusedMonth = DateTime(focusDate.year, focusDate.month, 1);
    _loadBlockedRanges();
  }

  Future<void> _loadBlockedRanges() async {
    try {
      final ranges = await widget.bookingRemoteDataSource.getBookedRanges(
        widget.vehicleId,
      );
      if (!mounted) return;
      setState(() {
        _blockedRanges = ranges
            .map(
              (item) => DateTimeRange(
                start: widget.dateOnly(item.startDate),
                end: widget.dateOnly(item.endDate),
              ),
            )
            .where((range) => !range.end.isBefore(widget.minDate))
            .toList();
        _isLoadingBlockedRanges = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingBlockedRanges = false;
        _loadError = e.toString().replaceFirst('Exception: ', '');
      });
      AppToast.show(
        null,
        message: _loadError ?? 'Không thể tải lịch đã đặt',
        type: AppToastType.error,
      );
    }
  }

  bool get _canGoPrevious {
    final previousMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month - 1,
      1,
    );
    return !previousMonth.isBefore(
      DateTime(widget.minDate.year, widget.minDate.month, 1),
    );
  }

  bool get _canGoNext {
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    return !nextMonth.isAfter(
      DateTime(widget.maxDate.year, widget.maxDate.month, 1),
    );
  }

  void _moveMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + delta,
        1,
      );
    });
  }

  bool _isBlockedDay(DateTime day) {
    final normalized = widget.dateOnly(day);
    return _blockedRanges.any(
      (range) =>
          !normalized.isBefore(range.start) && !normalized.isAfter(range.end),
    );
  }

  bool _doesCandidateOverlapBlockedRange(DateTime start, DateTime end) {
    final candidateStart = widget.dateOnly(start);
    final candidateEnd = widget.dateOnly(end);
    return _blockedRanges.any((range) {
      return !candidateStart.isAfter(range.end) &&
          !candidateEnd.isBefore(range.start);
    });
  }

  void _showOverlapWarning() {
    AppToast.show(
      null,
      message:
          'Trong khoảng thời gian này đã có người đặt lịch. Vui lòng chọn ngày khác.',
      type: AppToastType.warning,
    );
  }

  void _handleDayTap(DateTime day) {
    final normalized = widget.dateOnly(day);
    if (normalized.isBefore(widget.minDate) ||
        normalized.isAfter(widget.maxDate) ||
        _isBlockedDay(normalized)) {
      return;
    }

    if (_endDate != null || _startDate == null) {
      setState(() {
        _startDate = normalized;
        _endDate = null;
      });
      return;
    }

    if (widget.isSameDay(normalized, _startDate!)) {
      return;
    }

    final candidateStart = normalized.isBefore(_startDate!)
        ? normalized
        : _startDate!;
    final candidateEnd = normalized.isBefore(_startDate!)
        ? _startDate!
        : normalized;

    if (_doesCandidateOverlapBlockedRange(candidateStart, candidateEnd)) {
      setState(() {
        _startDate = normalized;
        _endDate = null;
      });
      _showOverlapWarning();
      return;
    }

    setState(() {
      _startDate = candidateStart;
      _endDate = candidateEnd;
    });
  }

  bool _isSelected(DateTime day) {
    final normalized = widget.dateOnly(day);
    return _endDate != null &&
        _startDate != null &&
        !normalized.isBefore(_startDate!) &&
        !normalized.isAfter(_endDate!);
  }

  Widget _buildDayCell(DateTime day) {
    final normalized = widget.dateOnly(day);
    final isStart =
        _startDate != null && widget.isSameDay(normalized, _startDate!);
    final isEnd = _endDate != null && widget.isSameDay(normalized, _endDate!);
    final isInRange = _isSelected(day);
    final isToday = widget.isSameDay(
      normalized,
      widget.dateOnly(DateTime.now()),
    );
    final isSelectedDay = isStart || isEnd || isInRange;
    final isDisabled =
        !isSelectedDay &&
        (normalized.isBefore(widget.minDate) ||
            normalized.isAfter(widget.maxDate) ||
            _isBlockedDay(normalized));

    BoxDecoration? decoration;
    Color textColor = AppColors.textPrimary;
    FontWeight fontWeight = FontWeight.w600;

    if (_isBlockedDay(normalized)) {
      decoration = BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(14),
      );
      textColor = AppColors.danger.withValues(alpha: 0.65);
    } else if (isStart) {
      decoration = BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );
      textColor = Colors.white;
      fontWeight = FontWeight.w800;
    } else if (isEnd) {
      decoration = BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );
      textColor = Colors.white;
      fontWeight = FontWeight.w800;
    } else if (isInRange) {
      decoration = BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      );
      textColor = AppColors.primary;
      fontWeight = FontWeight.w700;
    } else if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      );
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _handleDayTap(day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: decoration,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isDisabled
                    ? textColor.withValues(alpha: 0.35)
                    : textColor,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    final days = widget.daysForMonth(_focusedMonth);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) {
                return const SizedBox.shrink();
              }
              return _buildDayCell(day);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _LegendRow(color: AppColors.primary, label: 'Ngày bắt đầu'),
                const SizedBox(height: 8),
                _LegendRow(color: AppColors.danger, label: 'Ngày kết thúc'),
                const SizedBox(height: 8),
                _LegendRow(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  label: 'Ngày đã có lịch',
                  isRange: true,
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  label: 'Các ngày nằm giữa',
                  isRange: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _startDate == null || _endDate == null
                        ? 'Vui lòng chọn thời gian thuê xe'
                        : '${widget.formatBookingRangeWithTime(DateTimeRange(start: _startDate!, end: _endDate!))} (${_endDate!.difference(_startDate!).inDays < 1 ? 1 : _endDate!.difference(_startDate!).inDays} ngày)',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height * 0.88),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Chọn ngày thuê xe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _canGoPrevious
                              ? () => _moveMonth(-1)
                              : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                          color: AppColors.primary,
                        ),
                        Text(
                          widget.monthLabel(_focusedMonth),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: _canGoNext ? () => _moveMonth(1) : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final weekday = index + DateTime.monday;
                          return Expanded(
                            child: Center(
                              child: Text(
                                widget.weekdayShortLabel(weekday),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoadingBlockedRanges
                      ? const Center(
                          key: ValueKey('loading'),
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : _loadError != null
                      ? Center(
                          key: const ValueKey('error'),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cloud_off_rounded,
                                  color: AppColors.danger,
                                  size: 36,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                OutlinedButton(
                                  onPressed: _loadBlockedRanges,
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _buildCalendarContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            (_isLoadingBlockedRanges || _loadError != null)
                            ? null
                            : () {
                                if (_endDate == null) {
                                  AppToast.show(
                                    null,
                                    message: 'Vui lòng chọn thời gian thuê xe',
                                    type: AppToastType.error,
                                  );
                                  return;
                                }

                                if (_doesCandidateOverlapBlockedRange(
                                  _startDate!,
                                  _endDate!,
                                )) {
                                  _showOverlapWarning();
                                  return;
                                }
                                Navigator.of(context).pop(
                                  DateTimeRange(
                                    start: _startDate!,
                                    end: _endDate!,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.35,
                          ),
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final bool isRange;

  const _LegendRow({
    required this.color,
    required this.label,
    this.isRange = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isRange ? color : color,
            shape: isRange ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isRange ? BorderRadius.circular(6) : null,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.laneWhite,
      ),
    );
  }
}
