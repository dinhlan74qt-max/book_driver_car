import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';
import 'package:book_drive_car/features/home/domain/repositories/booking_repository.dart';
import 'package:book_drive_car/features/home/domain/repositories/home_repository.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/widgets/car_detail_booking_modal_sheet.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/widgets/car_detail_date_picker_sheet.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/widgets/car_detail_header_widgets.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_review_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_spec_grid.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_terms_card.dart';
import 'package:book_drive_car/features/profile/domain/repositories/verification_repository.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/identity_verification_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
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
  late CarEntity _car;

  CarEntity get car => _car;

  @override
  void initState() {
    super.initState();
    _car = widget.car;
    _selectedDateRange = null;
    _fetchCarDetail();
  }

  Future<void> _fetchCarDetail() async {
    try {
      final detail = await sl<HomeRepository>().getCarDetail(widget.car.id);
      if (mounted) {
        setState(() {
          _car = detail;
        });
      }
    } catch (_) {
      // Giữ thông tin xe ban đầu nếu không thể tải thêm
    }
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
          bookingRepository: sl<BookingRepository>(),
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
    final vData = await sl<VerificationRepository>().getVerificationData();
    if (vData.status != VerificationStatus.verified) {
      if (!context.mounted) return;
      _showVerificationRequiredDialog(context, vData);
      return;
    }

    if (vData.licenseExpiryDate != null &&
        vData.licenseExpiryDate!.isNotEmpty) {
      try {
        final parts = vData.licenseExpiryDate!.split('/');
        if (parts.length == 3) {
          final expiry = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
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

  void _showVerificationRequiredDialog(
    BuildContext context,
    VerificationData vData, {
    bool isExpired = false,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              'Xác minh tài khoản',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          isExpired
              ? 'Giấy phép lái xe của bạn đã hết hạn. Vui lòng cập nhật GPLX mới để tiếp tục đặt thuê xe.'
              : 'Bạn cần hoàn thành Xác minh danh tính & Giấy phép lái xe (KYC) trước khi bắt đầu thuê xe trên hệ thống.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      IdentityVerificationScreen(initialData: vData),
                ),
              );
            },
            child: const Text('Xác minh ngay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.getBackground(isDark);
    final surfaceColor = AppColors.getSurface(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final primaryColor = AppColors.getPrimary(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final textMuted = AppColors.getTextMuted(isDark);
    final surfaceSubtle = AppColors.getSurfaceSubtle(isDark);
    final tagBg = AppColors.getTagBg(isDark);
    final tagText = AppColors.getTagText(isDark);

    final images = car.imageUrls.isNotEmpty ? car.imageUrls : [car.imageIcon];
    final hasImages = images.any((e) => e.startsWith('http'));

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: context.isTablet ? 400 : 300,
                pinned: true,
                elevation: 0,
                backgroundColor: surfaceColor,
                foregroundColor: textPrimary,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GlassIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
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
                                  ? 'Đã thêm vào mục yêu thích'
                                  : 'Đã xóa khỏi mục yêu thích',
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
                          onPageChanged: (i) =>
                              setState(() => _currentImage = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: images[i],
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: AppColors.shimmerBase,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.primaryContainer,
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
                          color: AppColors.primaryContainer,
                          child: const Center(
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              size: 80,
                              color: AppColors.primary,
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
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
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
                    horizontal: context.isTablet ? 32 : 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên xe & Giá tiền
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
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tagBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        car.vehicleType,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: tagText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${car.rating} (Đánh giá cao)',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
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
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                '/ ngày',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Chọn thời gian thuê xe
                      TapScale(
                        onTap: () async {
                          final picked = await _pickDateRange(context);
                          if (picked != null) {
                            setState(() => _selectedDateRange = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.04,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thời gian thuê xe',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedDateRange != null
                                            ? _formatBookingRange(
                                                _selectedDateRange!,
                                              )
                                            : 'Chạm để chọn ngày nhận & trả xe',
                                        style: TextStyle(
                                          color: _selectedDateRange != null
                                              ? textPrimary
                                              : textSecondary,
                                          fontWeight: _selectedDateRange != null
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.edit_calendar_rounded,
                                      color: primaryColor,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Thông số kỹ thuật
                      const SectionTitle(title: 'Thông số kỹ thuật'),
                      const SizedBox(height: 12),
                      CarDetailSpecGrid(
                        specs: [
                          SpecItem(
                            icon: Icons.airline_seat_recline_normal_rounded,
                            label: 'Số chỗ',
                            value: '${car.seats} chỗ',
                          ),
                          SpecItem(
                            icon: Icons.local_gas_station_rounded,
                            label: 'Nhiên liệu',
                            value: car.fuelType ?? 'Xăng',
                          ),
                          SpecItem(
                            icon: Icons.settings_rounded,
                            label: 'Hộp số',
                            value: car.transmission ?? 'Tự động',
                          ),
                          const SpecItem(
                            icon: Icons.speed_rounded,
                            label: 'Mức tiêu hao',
                            value: '7.5L / 100km',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Đánh giá từ khách hàng
                      const SectionTitle(title: 'Đánh giá từ khách hàng'),
                      const SizedBox(height: 12),
                      const CarDetailReviewCard(
                        name: 'Nguyễn Văn Minh',
                        date: '12/03/2026',
                        rating: 5.0,
                        comment:
                            'Xe rất mới, sạch sẽ và máy chạy cực êm. Chủ xe nhiệt tình, thủ tục giao nhận nhanh gọn!',
                      ),
                      const SizedBox(height: 24),
                      const CarDetailTermsCard(),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Dock
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(top: BorderSide(color: borderColor, width: 0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng tạm tính',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatPrice(_totalPrice),
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppButton(
                        text: 'Đặt xe ngay',
                        height: 50,
                        onPressed: () => _handleBookingFlow(context),
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
}
